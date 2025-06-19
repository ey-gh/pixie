// ./src/controllers/claimsController.ts
import { Request, Response } from 'express';
import { getAllClaims, insertClaim } from '../db/claims';
import { sendSuccess, sendError } from '../utils/responses';

export async function getClaimsHandler(req: Request, res: Response) {
  try {
    const claims = await getAllClaims();
    return sendSuccess(res, claims);
  } catch (err) {
    console.error('GET /claims failed:', err);
    return sendError(res, 'Failed to fetch claims');
  }
}

export async function createClaimHandler(req: Request, res: Response) {
  const {
    client_id,
    invoice_id,
    authorization_id,
    service_date,
    location_id,
    status
  } = req.body;

  if (!client_id || !service_date) {
    return sendError(res, 'Missing required fields: client_id, service_date', 400);
  }

  try {
    const claim = await insertClaim({
      client_id,
      invoice_id,
      authorization_id,
      service_date,
      location_id,
      status
    });

    return sendSuccess(res, claim, 201);
  } catch (err) {
    console.error('POST /claims failed:', err);
    return sendError(res, 'Failed to create claim');
  }
}
