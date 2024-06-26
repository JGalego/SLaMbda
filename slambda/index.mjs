import util from 'util';
import stream from 'stream';
import { loadModel, createCompletionStream } from 'gpt4all';

const pipeline = util.promisify(stream.pipeline);

const model = await loadModel(process.env.MODEL_NAME, {
    allowDownload: false,
    modelPath: ".",
    modelConfigFile: "./models3.json",
    verbose: true,
    device: "cpu",
    nCtx: 2048,
});

export const handler = awslambda.streamifyResponse(async (event, responseStream, _context) => {
  const completionStream = createCompletionStream(model, JSON.parse(event.body).message, {verbose: true});
  await pipeline(completionStream.tokens, responseStream);
});