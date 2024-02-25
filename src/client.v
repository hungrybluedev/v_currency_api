module freecurrencyapi_v

import net.http
import net.urllib
import time
import x.json2

const status_url = 'https://api.freecurrencyapi.com/v1/status'
const currencies_url = 'https://api.freecurrencyapi.com/v1/currencies'
const latest_url = 'https://api.freecurrencyapi.com/v1/latest'

// APIQuota represents the quota of requests allowed for a specific timeframe like "month" or "grace".
pub struct APIQuota {
pub:
	total     int
	used      int
	remaining int
}

// APIStatus encapsulates the response from the status endpoint of the Free Currency API.
pub struct APIStatus {
pub:
	account_id string
	quotas     map[string]APIQuota
}

// CurrencyInfo represents all available information about a currency from the Free Currency API.
pub struct CurrencyInfo {
pub:
	symbol         string
	name           string
	symbol_native  string
	decimal_digits int
	rounding       int
	code           string
	name_plural    string
	currency_type  string @[json: 'type']
}

// ExchangeRatePair represents a pair of currencies and the exchange rate between them.
// It also includes the timestamp of the rate.
pub struct ExchangeRatePair {
pub:
	stamp          time.Time
	base_currency  string
	quote_currency string
	rate           f64
}

// extract_or_error is a utility function to extract a value from a json2.Any map or return an error if the key is not present.
fn extract_or_error(node map[string]json2.Any, key string) !json2.Any {
	return node[key] or { return error('Could not extract ${key} from JSON') }
}

// APIStatus.from_json parses a JSON string and returns an APIStatus object or an error if the JSON is invalid.
pub fn APIStatus.from_json(content string) !APIStatus {
	node := json2.raw_decode(content) or {
		return error('Failed to parse JSON with error:\n${err}')
	}

	node_map := node.as_map()
	account_id := extract_or_error(node_map, 'account_id')!.str()

	raw_quotas := extract_or_error(node_map, 'quotas')!.as_map()
	mut quotas := map[string]APIQuota{}
	for key, raw_value in raw_quotas {
		value := raw_value.as_map()
		quotas[key] = APIQuota{
			total: extract_or_error(value, 'total')!.int()
			used: extract_or_error(value, 'used')!.int()
			remaining: extract_or_error(value, 'remaining')!.int()
		}
	}

	return APIStatus{
		account_id: account_id
		quotas: quotas
	}
}

// APIClient is the entity that encapsulates the API key and provides methods to interact with the Free Currency API.
pub struct APIClient {
	api_key string
}

// get_status retrieves the account status from the Free Currency API. It returns an APIStatus object or an error if the request fails.
pub fn (client APIClient) get_status() !APIStatus {
	mut request := http.new_request(.get, freecurrencyapi_v.status_url, '')
	request.add_custom_header('apikey', client.api_key)!

	response := request.do() or { return error('Failed to make request with error:\n${err}') }

	if response.status_code != 200 {
		eprintln('Unexpected status code: ${response.status_code} with full response:\n${response}')
		return error('Failed to get status with status code ${response.status_code} and content:\n${response.body}')
	}

	return APIStatus.from_json(response.body) or {
		return error('Failed to parse status JSON with error:\n${err}')
	}
}

// get_currencies retrieves the list of currencies from the Free Currency API. It returns an error if the request fails.
pub fn (client APIClient) get_currencies() !map[string]CurrencyInfo {
	mut request := http.new_request(.get, freecurrencyapi_v.currencies_url, '')
	request.add_custom_header('apikey', client.api_key)!

	response := request.do() or { return error('Failed to make request with error:\n${err}') }

	if response.status_code != 200 {
		eprintln('Unexpected status code: ${response.status_code} with full response:\n${response}')
		return error('Failed to get status with status code ${response.status_code} and content:\n${response.body}')
	}

	full_node := json2.raw_decode(response.body) or {
		return error('Failed to parse JSON with error:\n${err}')
	}

	mut currencies := map[string]CurrencyInfo{}

	data_node := extract_or_error(full_node.as_map(), 'data')!.as_map()
	for key, value in data_node {
		info := json2.decode[CurrencyInfo](value.str()) or {
			return error('Failed to parse currency info with error:\n${err}')
		}
		currencies[key] = info
	}

	return currencies
}

// LatestRateConfig is the configuration parameter struct for the get_latest method.
// The base currency is optional and if not provided, the API will use the default base currency of USD.
// The currencies list is also optional and if not provided, the API will return the rates for all available currencies.
@[params]
pub struct LatestRateConfig {
	base_currency string
	currencies    []string
}

// get_latest retrieves the latest exchange rates from the Free Currency API. It returns a list of ExchangeRatePair objects or an error if the request fails.
pub fn (client APIClient) get_latest(config LatestRateConfig) ![]ExchangeRatePair {
	// Validate the configuration.
	if config.base_currency.len > 0 && config.base_currency.len != 3 {
		return error('Invalid base currency: ${config.base_currency}')
	}
	if config.currencies.len > 0 {
		for currency in config.currencies {
			if currency.len != 3 {
				return error('Invalid output currency: ${currency}')
			}
		}
	}

	// Prepare the request.
	mut params := urllib.new_values()
	if config.base_currency.len > 0 {
		params.add('base_currency', config.base_currency)
	}
	if config.currencies.len > 0 {
		params.add('currencies', config.currencies.join(','))
	}

	full_endpoint := '${currencies.latest_url}?${params.encode()}'

	mut request := http.new_request(.get, full_endpoint, '')
	request.add_custom_header('apikey', client.api_key)!

	response := request.do() or { return error('Failed to make request with error:\n${err}') }

	if response.status_code != 200 {
		eprintln('Unexpected status code: ${response.status_code} with full response:\n${response}')
		return error('Failed to get status with status code ${response.status_code} and content:\n${response.body}')
	}

	full_node := json2.raw_decode(response.body) or {
		return error('Failed to parse JSON with error:\n${err}')
	}

	data := extract_or_error(full_node.as_map(), 'data')!.as_map()

	mut rates := []ExchangeRatePair{}
	current_time := time.now()

	for key, value in data {
		rate := value.f64()
		rates << ExchangeRatePair{
			stamp: current_time
			base_currency: config.base_currency
			quote_currency: key
			rate: rate
		}
	}

	return rates
}
