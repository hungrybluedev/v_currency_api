# Free Currency Converter API for V

## Overview

This project is a wrapper for the HTTP API provided by [Free Currency Converter API](https://freecurrencyapi.com/). It provides a simple way to access the API using V.

> [!NOTE]
> An API key is required to use the API. It is free to sign
> up and at the time of writing, the free tier allows for 5000 requests per month.

## Installation

This package can be installed using the V package manager.

```bash
v install https://github.com/hungrybluedev/freecurrencyapi_v
```

## Usage

```v
import freecurrencyapi_v

fn main() {
	client := freecurrencyapi_v.APIClient{
		api_key: '<YOUR API KEY>'
	}

	status := client.get_status() or { panic('Failed to get status with error:\n${err}') }

	println(status)

	monthly_quota := status.quotas['month'] or { panic('Failed to get monthly quota') }

	if monthly_quota.remaining <= 0 {
		panic('Monthly quota exhausted.')
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
```

The output for this would be something like:

```
freecurrencyapi_v.APIStatus{
    account_id: '<YOUR ACCOUNT ID>'
    quotas: {'month': freecurrencyapi_v.APIQuota{
        total: 5000
        used: 19
        remaining: 4981
    }, 'grace': freecurrencyapi_v.APIQuota{
        total: 0
        used: 0
        remaining: 0
    }}
}
Currencies retrieved successfully:

EUR:
freecurrencyapi_v.CurrencyInfo{
    symbol: '€'
    name: 'Euro'
    symbol_native: '€'
    decimal_digits: 2
    rounding: 0
    code: 'EUR'
    name_plural: 'Euros'
    currency_type: 'fiat'
}

USD:
freecurrencyapi_v.CurrencyInfo{
    symbol: '$'
    name: 'US Dollar'
    symbol_native: '$'
    decimal_digits: 2
    rounding: 0
    code: 'USD'
    name_plural: 'US dollars'
    currency_type: 'fiat'
}

JPY:
freecurrencyapi_v.CurrencyInfo{
    symbol: '¥'
    name: 'Japanese Yen'
    symbol_native: '￥'
    decimal_digits: 0
    rounding: 0
    code: 'JPY'
    name_plural: 'Japanese yen'
    currency_type: 'fiat'
}

...

ZAR:
freecurrencyapi_v.CurrencyInfo{
    symbol: 'R'
    name: 'South African Rand'
    symbol_native: 'R'
    decimal_digits: 2
    rounding: 0
    code: 'ZAR'
    name_plural: 'South African rand'
    currency_type: 'fiat'
}

Latest rates retrieved successfully:
[freecurrencyapi_v.ExchangeRatePair{
    stamp: 2024-02-25 17:40:59
    base_currency: 'GBP'
    quote_currency: 'EUR'
    rate: 1.170789869
}, freecurrencyapi_v.ExchangeRatePair{
    stamp: 2024-02-25 17:40:59
    base_currency: 'GBP'
    quote_currency: 'INR'
    rate: 104.963237776
}, freecurrencyapi_v.ExchangeRatePair{
    stamp: 2024-02-25 17:40:59
    base_currency: 'GBP'
    quote_currency: 'USD'
    rate: 1.267362721
}]
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

If you have any urgent requests or need commercial support,
please book a call with me.

[![Book a call](https://img.shields.io/badge/Book%20a%20call-Consulting-blue?style=for-the-badge)](https://tidycal.com/hungrybluedev)
