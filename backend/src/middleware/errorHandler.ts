// global error middleware
// src/middleware/errorHandler.ts
import { Request, Response, NextFunction } from 'express';
import { sendError } from '../utils/responses';

export function errorHandler(
  err: Error,
  req: Request,
  res: Response,
  next: NextFunction
) {
  console.error(`[ERROR] ${req.method} ${req.originalUrl}:`, err.message);
  return sendError(res, 'Internal server error', 500);
}
