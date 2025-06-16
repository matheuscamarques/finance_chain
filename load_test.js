import http from 'k6/http';
import { check, sleep, group } from 'k6';

// Opções do teste: Simula um aumento gradual de usuários,
// mantém a carga e depois diminui.
export const options = {
  stages: [
    { duration: '30s', target: 50 },   // Aumenta de 0 para 50 usuários em 30 segundos
    { duration: '1m', target: 100 },  // Aumenta de 50 para 100 usuários em 1 minuto
    { duration: '2m', target: 100 },  // Mantém 100 usuários por 2 minutos
    { duration: '30s', target: 0 },    // Diminui para 0 usuários
  ],
  thresholds: {
    // Define que 95% das requisições devem terminar em menos de 800ms
    'http_req_duration': ['p(95)<800'],
    // Define que 99% das requisições devem ter o status de sucesso (sem erros)
    'checks': ['rate>0.99'],
  },
};

const BASE_URL = 'http://localhost:4000'; // ⚠️ Altere se sua porta for diferente

// A função 'setup' roda uma única vez no início do teste
export function setup() {
  console.log('🔥 Resetando o estado do sistema...');
  const res = http.post(`${BASE_URL}/reset`);
  check(res, { 'reset foi bem-sucedido': (r) => r.status === 200 });
  console.log('✅ Sistema pronto para o teste.');
}

// Esta é a função principal que cada usuário virtual (VU) irá executar em loop
export default function () {
  // Gera dois IDs de conta aleatórios e distintos, de 1 a 1,000,000
  const account1 = Math.floor(Math.random() * 1000000) + 1;
  let account2 = Math.floor(Math.random() * 1000000) + 1;
  while (account1 === account2) {
    account2 = Math.floor(Math.random() * 1000000) + 1;
  }

  const amount = Math.floor(Math.random() * 100) + 10; // Valor entre 10 e 110

  // Agrupa as operações para melhor organização nos resultados
  group('Cenário de Transferência Completa', function () {
    // 1. Deposita um valor inicial na primeira conta
    const depositPayload = JSON.stringify({
      type: 'deposit',
      destination: account1.toString(),
      amount: amount * 2, // Garante que a conta1 tenha saldo suficiente
    });

    const depositRes = http.post(`${BASE_URL}/event`, depositPayload, {
      headers: { 'Content-Type': 'application/json' },
    });

    check(depositRes, {
      'depósito criou a conta com sucesso (status 201)': (r) => r.status === 201,
    });

    // Pequena pausa para simular o "tempo de pensamento" do usuário
    sleep(1);

    // 2. Transfere um valor da conta 1 para a conta 2
    const transferPayload = JSON.stringify({
      type: 'transfer',
      origin: account1.toString(),
      destination: account2.toString(),
      amount: amount,
    });

    const transferRes = http.post(`${BASE_URL}/event`, transferPayload, {
      headers: { 'Content-Type': 'application/json' },
    });

    check(transferRes, {
      'transferência entre contas foi bem-sucedida (status 201)': (r) => r.status === 201,
    });
  });

  sleep(1); // Pausa antes do próximo VU iniciar sua iteração
}