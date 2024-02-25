module main

import freecurrencyapi_v
import os

fn main() {
	client := freecurrencyapi_v.APIClient{
		api_key: os.getenv_opt('FREE_CURRENCY_API_KEY') or {
			eprintln('Please set the environment variable FREE_CURRENCY_API_KEY')
			return
		}
	}

	status := client.get_status() or {
		eprintln('Failed to get status with error:\n${err}')
		return
	}

	println(status)

	monthly_quota := status.quotas['month'] or {
		eprintln('Failed to get monthly quota')
		return
	}

	if monthly_quota.remaining <= 4500 {
		eprintln('Monthly quota exhausted for CI runs. Please run this example locally or use your own API key.')
		return
	}

	currencies := client.get_currencies() or {
		eprintln('Failed to get currencies with error:\n${err}')
		return
	}

	println('Currencies retrieved successfully:\n')
	for key, value in currencies {
		println('${key}:\n${value}\n')
	}

	rates := client.get_latest(base_currency: 'GBP', currencies: ['INR', 'USD', 'EUR']) or {
		eprintln('Failed to get latest rates with error:\n${err}')
		return
	}
	println('Latest rates retrieved successfully:\n${rates}')
}
