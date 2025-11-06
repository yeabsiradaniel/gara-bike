
const { PrismaClient } = require('@prisma/client');
const fs = require('fs');

// Prisma client for the new MongoDB database
const prismaMongo = new PrismaClient();

// Prisma client for the old SQLite database
const prismaSqlite = new PrismaClient({
  datasources: {
    db: {
      url: 'file:../prisma/dev.db',
    },
  },
});

async function migrate() {
  try {
    console.log('Starting data migration...');

    // Migrate models without dependencies first
    const corporateAccounts = await prismaSqlite.corporateAccount.findMany();
    const newCorporateAccounts = [];
    for (const account of corporateAccounts) {
        const newAccount = await prismaMongo.corporateAccount.create({ data: { ...account, id: undefined } });
        newCorporateAccounts.push({ oldId: account.id, newId: newAccount.id });
    }
    console.log(`Migrated ${corporateAccounts.length} corporate accounts.`);

    const parkingZones = await prismaSqlite.parkingZone.findMany();
    await prismaMongo.parkingZone.createMany({ data: parkingZones.map(p => ({...p, id: undefined})) });
    console.log(`Migrated ${parkingZones.length} parking zones.`);

    const passes = await prismaSqlite.pass.findMany();
    const newPasses = [];
    for (const pass of passes) {
        const newPass = await prismaMongo.pass.create({ data: { ...pass, id: undefined } });
        newPasses.push({ oldId: pass.id, newId: newPass.id });
    }
    console.log(`Migrated ${passes.length} passes.`);

    // Migrate users and map old IDs to new IDs
    const users = await prismaSqlite.user.findMany();
    const newUsers = [];
    for (const user of users) {
        const corporateAccountRelation = newCorporateAccounts.find(acc => acc.oldId === user.corporateAccountId);
        const newUser = await prismaMongo.user.create({
            data: {
                ...user,
                id: undefined,
                corporateAccountId: corporateAccountRelation ? corporateAccountRelation.newId : null,
            }
        });
        newUsers.push({ oldId: user.id, newId: newUser.id });
    }
    console.log(`Migrated ${users.length} users.`);

    // Migrate bikes and map old IDs to new IDs
    const bikes = await prismaSqlite.bike.findMany();
    const newBikes = [];
    for (const bike of bikes) {
        const reservedByUserRelation = newUsers.find(u => u.oldId === bike.reservedById);
        const newBike = await prismaMongo.bike.create({
            data: {
                ...bike,
                id: undefined,
                reservedById: reservedByUserRelation ? reservedByUserRelation.newId : null,
            }
        });
        newBikes.push({ oldId: bike.id, newId: newBike.id });
    }
    console.log(`Migrated ${bikes.length} bikes.`);

    // Migrate rides
    const rides = await prismaSqlite.ride.findMany();
    for (const ride of rides) {
        const userRelation = newUsers.find(u => u.oldId === ride.userId);
        const bikeRelation = newBikes.find(b => b.oldId === ride.bikeId);
        if (userRelation && bikeRelation) {
            await prismaMongo.ride.create({
                data: {
                    ...ride,
                    id: undefined,
                    userId: userRelation.newId,
                    bikeId: bikeRelation.newId,
                }
            });
        }
    }
    console.log(`Migrated ${rides.length} rides.`);

    // Migrate wallets
    const wallets = await prismaSqlite.wallet.findMany();
    const newWallets = [];
    for (const wallet of wallets) {
        const userRelation = newUsers.find(u => u.oldId === wallet.userId);
        if (userRelation) {
            const newWallet = await prismaMongo.wallet.create({
                data: {
                    ...wallet,
                    id: undefined,
                    userId: userRelation.newId,
                }
            });
            newWallets.push({ oldId: wallet.id, newId: newWallet.id });
        }
    }
    console.log(`Migrated ${wallets.length} wallets.`);

    // Migrate transactions
    const transactions = await prismaSqlite.transaction.findMany();
    for (const transaction of transactions) {
        const walletRelation = newWallets.find(w => w.oldId === transaction.walletId);
        if (walletRelation) {
            await prismaMongo.transaction.create({
                data: {
                    ...transaction,
                    id: undefined,
                    walletId: walletRelation.newId,
                }
            });
        }
    }
    console.log(`Migrated ${transactions.length} transactions.`);

    // Migrate support tickets
    const supportTickets = await prismaSqlite.supportTicket.findMany();
    for (const ticket of supportTickets) {
        const userRelation = newUsers.find(u => u.oldId === ticket.userId);
        if (userRelation) {
            await prismaMongo.supportTicket.create({
                data: {
                    ...ticket,
                    id: undefined,
                    userId: userRelation.newId,
                }
            });
        }
    }
    console.log(`Migrated ${supportTickets.length} support tickets.`);

    // Migrate user passes
    const userPasses = await prismaSqlite.userPass.findMany();
    for (const userPass of userPasses) {
        const userRelation = newUsers.find(u => u.oldId === userPass.userId);
        const passRelation = newPasses.find(p => p.oldId === userPass.passId);
        if (userRelation && passRelation) {
            await prismaMongo.userPass.create({
                data: {
                    ...userPass,
                    id: undefined,
                    userId: userRelation.newId,
                    passId: passRelation.newId,
                }
            });
        }
    }
    console.log(`Migrated ${userPasses.length} user passes.`);

    // Migrate bike reports
    const bikeReports = await prismaSqlite.bikeReport.findMany();
    for (const report of bikeReports) {
        const userRelation = newUsers.find(u => u.oldId === report.userId);
        const bikeRelation = newBikes.find(b => b.oldId === report.bikeId);
        if (userRelation && bikeRelation) {
            await prismaMongo.bikeReport.create({
                data: {
                    ...report,
                    id: undefined,
                    userId: userRelation.newId,
                    bikeId: bikeRelation.newId,
                }
            });
        }
    }
    console.log(`Migrated ${bikeReports.length} bike reports.`);

    console.log('Data migration completed successfully!');

  } catch (error) {
    console.error('Failed to migrate data:', error);
  } finally {
    await prismaSqlite.$disconnect();
    await prismaMongo.$disconnect();
  }
}

migrate();
