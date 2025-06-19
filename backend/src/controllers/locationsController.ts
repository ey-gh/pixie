// ./src/controllers/locationsController.ts
import { Request, Response } from 'express';
import { getAllLocations, insertLocation } from '../db/locations';
import { sendSuccess, sendError } from '../utils/responses';

export async function getLocationsHandler(req: Request, res: Response) {
  try {
    const locations = await getAllLocations();
    return sendSuccess(res, locations);
  } catch (err) {
    console.error('GET /locations failed:', err);
    return sendError(res, 'Failed to retrieve locations');
  }
}

export async function createLocationHandler(req: Request, res: Response) {
  const { name, address_street, address_city, address_state, address_zip } = req.body;

  if (!name) {
    return sendError(res, 'Missing required field: name', 400);
  }

  try {
    const newLocation = await insertLocation({
      name,
      address_street,
      address_city,
      address_state,
      address_zip,
    });
    return sendSuccess(res, newLocation, 201);
  } catch (err) {
    console.error('POST /locations failed:', err);
    return sendError(res, 'Failed to create location', 500);
  }
}
