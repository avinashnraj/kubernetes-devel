import http from 'k6/http';
import { sleep } from 'k6';

export let options = {
    vus: 10, // Number of virtual users
    duration: '1m', // Duration of the test
};

export default function () {
    http.get('http://nginx-lua-service:80'); // Service IP to test
    sleep(1); // Pause for 1 second
}

