const db = require('../config/Database');
const Vehicles = require('../models/VehicleModel');
const seedData = require('./seedData');

const seedDatabase = async () => {
  try {
    const existingVehicles = await Vehicles.findAll();
    if (existingVehicles.length === 0) {
      await db.sync();
      await Vehicles.bulkCreate(seedData);
      console.log('Seed data inserted into the database.');
    } else {
      console.log('Database already contains data. No need to run the seed script.');
    }
  } catch (error) {
    console.error('Error inserting seed data:', error);
  }
};

seedDatabase();