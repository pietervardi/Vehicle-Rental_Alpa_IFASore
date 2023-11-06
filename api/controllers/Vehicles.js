const Vehicle = require('../models/VehicleModel');

// Get Data
const getVehicles = async (req, res) => {
  try {
    let response;
    response = await Vehicle.findAll({
      attributes: ['id', 'name', 'brand', 'image', 'price', 'color', 'gearbox', 'seat', 'fuel', 'power', 'book', 'date'],
    });
    res.status(200).json(response);
  } catch (error) {
    res.status(500).json({ msg: error.message });
  }
};

// Update Data (Book & Date)
const updateVehicles =  async (req, res) => {
  try {
    const vehicleId = req.params.id;
    const { book, date } = req.body;

    if (typeof book !== 'boolean') {
      return res.status(400).json({ msg: 'Invalid "book" value. It should be a boolean (true or false).' });
    }

    const updatedVehicle = await Vehicle.findByPk(vehicleId);

    if (!updatedVehicle) {
      return res.status(404).json({ msg: 'Vehicle not found.' });
    }

    updatedVehicle.book = book;
    updatedVehicle.date = date;

    await updatedVehicle.save();

    res.status(200).json(updatedVehicle);
  } catch (error) {
    res.status(500).json({ msg: error.message });
  }
};

module.exports = { getVehicles, updateVehicles };