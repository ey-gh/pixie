// src/controllers/clientsController.ts
import { RequestHandler } from 'express';
import { getAllClients, insertClient } from '../db/clients';
import { sendSuccess, sendError } from '../utils/responses';

export const getClientsHandler: RequestHandler = async (req, res) => {
  try {
    const clients = await getAllClients();
    return sendSuccess(res, clients);
  } catch (err) {
    console.error('GET /clients failed:', err);
    return sendError(res, 'Failed to fetch clients', 500);
  }
};

export const createClientHandler: RequestHandler = async (req, res) => {
  const { first_name, last_name, dob, address_city, address_state, address_zip } = req.body;

  if (!first_name || !last_name || !dob) {
    return sendError(res, 'Missing required fields: first_name, last_name, dob', 400);
  }

  try {
    const newClient = await insertClient({
      first_name,
      last_name,
      dob,
      address_city,
      address_state,
      address_zip,
    });

    return sendSuccess(res, newClient, 201);
  } catch (err) {
    console.error('POST /clients failed:', err instanceof Error ? err.stack : err);
    return sendError(res, 'Failed to create client', 500);
  }
};
