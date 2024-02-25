module main

import currencies

fn main() {
	client := APIClient{
		api_key: '<READ THIS FROM A CONFIG FILE>'
	}

	status := client.get_status() or {
		eprintln('Failed to get status with error:\n${err}')
		return
	}

	println(status)

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
