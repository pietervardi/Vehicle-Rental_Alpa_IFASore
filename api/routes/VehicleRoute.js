const express = require('express');
const { getVehicles, updateVehicles } = require('../controllers/Vehicles')

const router = express.Router();

router.get('/vehicles', getVehicles);
router.patch('/vehicles/:id', updateVehicles);

module.exports = router;