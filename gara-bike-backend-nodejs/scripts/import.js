const { PrismaClient } = require('@prisma/client');
const fs = require('fs');
const prisma = new PrismaClient();

async function importData() {
  try {
    console.log('Importing data into MongoDB...');

    const data = JSON.parse(fs.readFileSync('./scripts/migration-data.json', 'utf-8'));

    // Clear existing data
    await prisma.bikeReport.deleteMany({});
    await prisma.userPass.deleteMany({});
    await prisma.supportTicket.deleteMany({});
    await prisma.transaction.deleteMany({});
    await prisma.wallet.deleteMany({});
    await prisma.ride.deleteMany({});
    await prisma.bike.deleteMany({});
    await prisma.user.deleteMany({});
    await prisma.pass.deleteMany({});
    await prisma.parkingZone.deleteMany({});
    await prisma.corporateAccount.deleteMany({});
    console.log('Cleared existing data from MongoDB.');

    const idMaps = {};
    const reservedUserIds = new Set();

    // Import corporate accounts
    idMaps.corporateAccounts = {};
    for (const account of data.corporateAccounts) {
      const newAccount = await prisma.corporateAccount.create({
        data: { 
            ...account, 
            id: undefined,
            discountPercentage: parseFloat(account.discountPercentage)
        },
      });
      idMaps.corporateAccounts[account.id] = newAccount.id;
    }
    console.log(`Imported ${data.corporateAccounts.length} corporate accounts.`);

    // Import users
    idMaps.users = {};
    for (const user of data.users) {
      const newUser = await prisma.user.create({
        data: {
          ...user,
          id: undefined,
          corporateAccountId: user.corporateAccountId ? idMaps.corporateAccounts[user.corporateAccountId] : null,
          totalDistanceMeters: parseFloat(user.totalDistanceMeters),
          homeAddressLat: user.homeAddressLat ? parseFloat(user.homeAddressLat) : null,
          homeAddressLon: user.homeAddressLon ? parseFloat(user.homeAddressLon) : null,
          workAddressLat: user.workAddressLat ? parseFloat(user.workAddressLat) : null,
          workAddressLon: user.workAddressLon ? parseFloat(user.workAddressLon) : null,
        },
      });
      idMaps.users[user.id] = newUser.id;
    }
    console.log(`Imported ${data.users.length} users.`);

    // Import parking zones
    await prisma.parkingZone.createMany({ data: data.parkingZones.map(p => ({...p, id: undefined, latitude: parseFloat(p.latitude), longitude: parseFloat(p.longitude)})) });
    console.log(`Imported ${data.parkingZones.length} parking zones.`);

    // Import passes
    idMaps.passes = {};
    for (const pass of data.passes) {
        const newPass = await prisma.pass.create({ data: { ...pass, id: undefined, price: parseFloat(pass.price) } });
        idMaps.passes[pass.id] = newPass.id;
    }
    console.log(`Imported ${data.passes.length} passes.`);

    // Import bikes
    idMaps.bikes = {};
    console.log('--- Starting Bike Import --- ');
    for (const bike of data.bikes) {
        try {
            const bikeData = {
                qrCode: bike.qrCode,
                status: bike.status,
                batteryLevel: bike.batteryLevel,
                lastReportedAt: bike.lastReportedAt,
                reservationExpiresAt: bike.reservationExpiresAt,
                latitude: bike.latitude ? parseFloat(bike.latitude) : null,
                longitude: bike.longitude ? parseFloat(bike.longitude) : null,
            };

            if (bike.reservedById) {
                const newUserId = idMaps.users[bike.reservedById];
                if (newUserId && !reservedUserIds.has(newUserId)) {
                    bikeData.reservedById = newUserId;
                    reservedUserIds.add(newUserId);
                }
            }

            const newBike = await prisma.bike.create({ data: bikeData });
            idMaps.bikes[bike.id] = newBike.id;
        } catch (error) {
            console.error(`Failed to import bike with old ID: ${bike.id}. Data:`, JSON.stringify(bike, null, 2));
            console.error('Error:', error.message);
        }
    }
    console.log(`Finished bike import process.`);

    // Import rides
    for (const ride of data.rides) {
        await prisma.ride.create({
            data: {
                ...ride,
                id: undefined,
                userId: idMaps.users[ride.userId],
                bikeId: idMaps.bikes[ride.bikeId],
                startLatitude: parseFloat(ride.startLatitude),
                startLongitude: parseFloat(ride.startLongitude),
                endLatitude: ride.endLatitude ? parseFloat(ride.endLatitude) : null,
                endLongitude: ride.endLongitude ? parseFloat(ride.endLongitude) : null,
                cost: ride.cost ? parseFloat(ride.cost) : null,
                distanceMeters: ride.distanceMeters ? parseFloat(ride.distanceMeters) : null,
            }
        });
    }
    console.log(`Imported ${data.rides.length} rides.`);

    // Import wallets
    idMaps.wallets = {};
    for (const wallet of data.wallets) {
        const newWallet = await prisma.wallet.create({
            data: {
                ...wallet,
                id: undefined,
                userId: idMaps.users[wallet.userId],
                balance: parseFloat(wallet.balance),
            }
        });
        idMaps.wallets[wallet.id] = newWallet.id;
    }
    console.log(`Imported ${data.wallets.length} wallets.`);

    // Import transactions
    for (const transaction of data.transactions) {
        await prisma.transaction.create({
            data: {
                ...transaction,
                id: undefined,
                walletId: idMaps.wallets[transaction.walletId],
                amount: parseFloat(transaction.amount),
            }
        });
    }
    console.log(`Imported ${data.transactions.length} transactions.`);

    // Import support tickets
    for (const ticket of data.supportTickets) {
        await prisma.supportTicket.create({
            data: {
                ...ticket,
                id: undefined,
                userId: idMaps.users[ticket.userId],
            }
        });
    }
    console.log(`Imported ${data.supportTickets.length} support tickets.`);

    // Import user passes
    for (const userPass of data.userPasses) {
        await prisma.userPass.create({
            data: {
                ...userPass,
                id: undefined,
                userId: idMaps.users[userPass.userId],
                passId: idMaps.passes[userPass.passId],
            }
        });
    }
    console.log(`Imported ${data.userPasses.length} user passes.`);

    // Import bike reports
    for (const report of data.bikeReports) {
        await prisma.bikeReport.create({
            data: {
                ...report,
                id: undefined,
                userId: idMaps.users[report.userId],
                bikeId: idMaps.bikes[report.bikeId],
            }
        });
    }
    console.log(`Imported ${data.bikeReports.length} bike reports.`);

    console.log('Data imported successfully!');

  } catch (error) {
    console.error('Failed to import data:', error);
  } finally {
    await prisma.$disconnect();
  }
}

importData();
