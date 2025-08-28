import Fastify from 'fastify';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();
const fastify = Fastify({
  logger: true,
});

// Health check
fastify.get('/health', async (request, reply) => {
  return { status: 'healthy', service: 'formula' };
});

// Get all formulas for a user
fastify.get('/formulas', async (request, reply) => {
  // TODO: Add authentication middleware
  // TODO: Get userId from JWT token
  const userId = 'temp-user-id';
  
  const formulas = await prisma.formula.findMany({
    where: { userId },
    include: {
      metrics: {
        include: {
          metric: true,
        },
      },
    },
  });
  
  return { success: true, data: formulas };
});

// Create a new formula
fastify.post('/formulas', async (request, reply) => {
  // TODO: Add validation with Zod
  // TODO: Add authentication
  const { name, description, metrics } = request.body as any;
  
  const formula = await prisma.formula.create({
    data: {
      name,
      description,
      userId: 'temp-user-id',
      metrics: {
        create: metrics,
      },
    },
  });
  
  return { success: true, data: formula };
});

const start = async () => {
  try {
    const port = parseInt(process.env.FORMULA_SERVICE_PORT || '3002', 10);
    await fastify.listen({ port, host: '0.0.0.0' });
    console.log(`Formula service listening on port ${port}`);
  } catch (err) {
    fastify.log.error(err);
    process.exit(1);
  }
};

start();