import express from 'express';
import controller from '../controllers/transpiler';
const router = express.Router();

router.get('/transpile', controller.transpileEndpoint);

export default router;