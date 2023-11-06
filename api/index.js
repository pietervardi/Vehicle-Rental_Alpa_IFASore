const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');

const VehicleRoute = require('./routes/VehicleRoute');
const db = require('./config/Database');

dotenv.config();
const app = express();

const startServer = async () => {
  try {
    await db.sync();
    console.log('Database synchronized.');
    require('./data/seedDatabase');
  } catch (error) {
    console.error('Error syncing database:', error);
  }

  app.use(cors());
  app.use(express.json());
  app.use(VehicleRoute);

  app.listen(process.env.APP_PORT, () => {
    console.log(`Listening to port ${process.env.APP_PORT}`);
  });
};

startServer();