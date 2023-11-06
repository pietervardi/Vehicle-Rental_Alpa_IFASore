const { Sequelize } = require('sequelize');

const db = new Sequelize('vehicle_db', 'root', '', {
  dialect: 'sqlite',
  host: './data/dev.sqlite'
});

module.exports = db;