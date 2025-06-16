import http from 'k6/http';
import { check, sleep } from 'k6';
import { textSummary } from 'https://jslib.k6.io/k6-summary/0.0.1/index.js';

// MUDANÇA 1: Variável para configurar a carga máxima
const MAX_ACCOUNTS_AND_VUS = 500;

export const options = {
    stages: [
        { duration: '30s', target: Math.round(MAX_ACCOUNTS_AND_VUS * 0.4) },
        { duration: '1m', target: MAX_ACCOUNTS_AND_VUS },
        { duration: '30s', target: MAX_ACCOUNTS_AND_VUS * 2 },
        { duration: '2m', target: MAX_ACCOUNTS_AND_VUS },
        { duration: '30s', target: MAX_ACCOUNTS_AND_VUS * 4 },
        { duration: '5m', target: MAX_ACCOUNTS_AND_VUS * 10 },
        { duration: '1m', target: MAX_ACCOUNTS_AND_VUS * 5 },
        { duration: '30s', target: 0 },
    ],
    thresholds: {
        'http_req_duration': ['p(95)<1500'],
        // O threshold de checks valida que a grande maioria das respostas
        // está dentro dos status que consideramos válidos.
        'checks': ['rate>0.999'],
    },
};

const BASE_URL = 'http://localhost:4000';

// MUDANÇA 2: A lista de todos os status que NÃO são considerados erros críticos.
const ACCEPTABLE_STATUSES = [201, 404, 422];

/**
 * Verifica se o status da resposta está na lista de status aceitáveis.
 * Se não estiver, registra um erro crítico detalhado.
 */
function checkAndLogCriticalError(response, operationType, payload = {}) {
    const checkPassed = check(response, {
        [`${operationType} - status é aceitável (${ACCEPTABLE_STATUSES.join(',')})`]: (r) =>
            ACCEPTABLE_STATUSES.includes(r.status),
    });

    if (!checkPassed) {
        let responseBody;
        try { responseBody = JSON.parse(response.body); } catch (e) { responseBody = response.body; }

        console.error(JSON.stringify({
            timestamp: new Date().toISOString(),
            tipo_operacao: operationType,
            status_recebido_INESPERADO: response.status,
            corpo_resposta: responseBody,
            payload_enviado: payload,
            url_requisitada: response.request.url,
        }));
    }
}

/**
 * Roda uma vez antes do início para resetar o estado.
 */
export function setup() {
    console.log('🔥 Resetando o estado do sistema...');
    http.post(`${BASE_URL}/reset`);
    console.log('✅ Sistema pronto para o teste.');
}

/**
 * Função principal que cada usuário virtual executa em loop.
 * As operações são totalmente aleatórias, sem pré-financiamento.
 */
export default function () {
    const operation = Math.random();

    // IDs e valores são gerados de forma totalmente aleatória,
    // o que pode ou não resultar em erros de negócio.
    const origin = Math.floor(Math.random() * MAX_ACCOUNTS_AND_VUS * 2) + 1;
    let destination = Math.floor(Math.random() * MAX_ACCOUNTS_AND_VUS) + 1;
    while (origin === destination) {
        destination = Math.floor(Math.random() * MAX_ACCOUNTS_AND_VUS) + 1;
    }
    const amount = Math.floor(Math.random() * 200) + 1;

    // A lógica de operação aleatória
    if (operation < 0.5) {
        // 50% de chance: DEPÓSITO
        const payload = { type: 'deposit', destination: origin.toString(), amount: amount };
        const res = http.post(`${BASE_URL}/event`, JSON.stringify(payload), { headers: { 'Content-Type': 'application/json' } });
        checkAndLogCriticalError(res, 'deposit', payload);

    } else if (operation < 0.75) {
        // 25% de chance: RETIRADA (SAQUE)
        const payload = { type: 'withdraw', origin: origin.toString(), amount: amount };
        const res = http.post(`${BASE_URL}/event`, JSON.stringify(payload), { headers: { 'Content-Type': 'application/json' } });
        checkAndLogCriticalError(res, 'withdraw', payload);

    } else {
        // 25% de chance: TRANSFERÊNCIA
        const payload = { type: 'transfer', origin: origin.toString(), destination: destination.toString(), amount: amount };
        const res = http.post(`${BASE_URL}/event`, JSON.stringify(payload), { headers: { 'Content-Type': 'application/json' } });
        checkAndLogCriticalError(res, 'transfer', payload);
    }

    sleep(0.1);
}

/**
 * Roda no final para apresentar o sumário no console.
 */
export function handleSummary(data) {
    return {
        'stdout': textSummary(data, { indent: ' ', enableColors: true }),
    };
}