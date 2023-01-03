import { transpile, compileSolFiles, AST } from '@nethermindeth/warp';
import fs from 'fs';
import { Request, Response, NextFunction } from 'express';
import axios, { AxiosResponse } from 'axios';

const transpileContent = (content: string, filename: string) => {
    fs.writeFileSync(filename, content);
    const b = compileSolFiles([filename], { warnings: false });
    const a = transpile(b, { strict: true, dev: true });
    fs.rmSync(filename);
    return a;
}

const transpileEndpoint = async (req: Request, res: Response, next: NextFunction) => {
    const { content, filename } = req.query;
    const result = transpileContent(content as string, filename as string);
    res.send(result);
}

export default { transpileEndpoint }