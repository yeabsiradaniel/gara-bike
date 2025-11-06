const { PrismaClient } = require('@prisma/client');
const fs = require('fs');
const prisma = new PrismaClient();

async function exportData() {
  try {
    console.log('Exporting data from SQLite...');

    const data = {
      corporateAccounts: await prisma.corporateAccount.findMany(),
      users: await prisma.user.findMany(),
      parkingZones: await prisma.parkingZone.findMany(),
      bikes: await prisma.bike.findMany(),
      rides: await prisma.ride.findMany(),
      wallets: await prisma.wallet.findMany(),
      transactions: await prisma.transaction.findMany(),
      supportTickets: await prisma.supportTicket.findMany(),
      passes: await prisma.pass.findMany(),
      userPasses: await prisma.userPass.findMany(),
      bikeReports: await prisma.bikeReport.findMany(),
    };

    fs.writeFileSync('./scripts/migration-data.json', JSON.stringify(data, null, 2));

    console.log('Data exported successfully to migration-data.json');

  } catch (error) {
    console.error('Failed to export data:', error);
  } finally {
    await prisma.$disconnect();
  }
}

exportData();
