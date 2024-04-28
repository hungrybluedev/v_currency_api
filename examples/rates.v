module main

import v_currency_api
import os

fn main() {
	client := v_currency_api.APIClient{
		api_key: os.getenv_opt('FREE_CURRENCY_API_KEY') or {
			panic('Please set the environment variable FREE_CURRENCY_API_KEY')
		}
	}

	status := client.get_status() or { panic('Failed to get status with error:\n${err}') }

	println(status)

	monthly_quota := status.quotas['month'] or { panic('Failed to get monthly quota') }

	if monthly_quota.remaining <= 4500 {
		panic('Monthly quota exhausted for CI runs. Please run this example locally or use your own API key.')
	}

	currencies := client.get_currencies() or {
		panic('Failed to get currencies with error:\n${err}')
	}

	println('Currencies retrieved successfully:\n')
	for key, value in currencies {
		println('${key}:\n${value}\n')
	}

	rates := client.get_latest(base_currency: 'GBP', currencies: ['INR', 'USD', 'EUR']) or {
		panic('Failed to get latest rates with error:\n${err}')
	}
	println('Latest rates retrieved successfully:\n${rates}')
}
