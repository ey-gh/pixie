// ./src/routes/claims.ts
import { Router } from 'express';
import { getClaimsHandler, createClaimHandler } from '../controllers/claimsController';

const router = Router();

router.get('/', getClaimsHandler);
router.post('/', createClaimHandler);

export default router;
