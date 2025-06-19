// ./src/controllers/locationsController.ts
import { Request, Response } from 'express';
import { getAllAuthorizations, insertAuthorization } from '../db/authorizations';
import { sendSuccess, sendError } from '../utils/responses';

export async function getAuthorizationsHandler(req: Request, res: Response) {
  try {
    const data = await getAllAuthorizations();
    return sendSuccess(res, data);
  } catch (err) {
    console.error('GET /authorizations failed:', err);
    return sendError(res, 'Failed to fetch authorizations');
  }
}

export async function createAuthorizationHandler(req: Request, res: Response) {
  const {
    client_id,
    insurance_provider_id,
    payer_id,
    authorization_number,
    start_date,
    end_date,
    status,
    notes,
  } = req.body;

  if (!client_id || !insurance_provider_id || !start_date || !end_date) {
    return sendError(res, 'Missing required fields: client_id, insurance_provider_id, start_date, end_date', 400);
  }

  try {
    const inserted = await insertAuthorization({
      client_id,
      insurance_provider_id,
      payer_id,
      authorization_number,
      start_date,
      end_date,
      status,
      notes,
    });

    return sendSuccess(res, inserted, 201);
  } catch (err) {
    console.error('POST /authorizations failed:', err);
    return sendError(res, 'Failed to create authorization');
  }
}
