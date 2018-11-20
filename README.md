# crypto-funds-exporter
Allows to export your crypto stock exchange's funds into Prometheus

![crypto-funds-exporter](https://user-images.githubusercontent.com/418868/48798765-6ab35080-ed16-11e8-9d61-2c438fbfa5ab.png)

## Build and run Docker container from scratch

```bash
git clone https://github.com/a0s/crypto-funds-exporter.git
cd crypto-funds-exporter
git checkout v0.0.2
docker build --tag crypto-funds-exporter .
```

You can choose stock(s) exchange for monitoring by settings xxx_KEY/yyy_SECRET keys.
You can set only one stock exchange if you want.

It is recommended to use only tokens with read-only permissions.

Stock exchanges supported by crypto-funds-exporter: 

* Bittrex
  ```
  CRYPTO_FUNDS_EXPORTER_BITTREX_KEY
  CRYPTO_FUNDS_EXPORTER_BITTREX_SECRET
  ```
    
* Binance
  ```
  CRYPTO_FUNDS_EXPORTER_BINANCE_KEY
  CRYPTO_FUNDS_EXPORTER_BINANCE_SECRET
  ```

* Kucoin
  ```
  CRYPTO_FUNDS_EXPORTER_KUCOIN_KEY
  CRYPTO_FUNDS_EXPORTER_KUCOIN_SECRET
  ```
    
Start container with chosen stock exchanges
    
```bash
docker run \
    --restart always \
    -td \
    -p 9518:9518 \
    -e CRYPTO_FUNDS_EXPORTER_BITTREX_KEY=... \
    -e CRYPTO_FUNDS_EXPORTER_BITTREX_SECRET=... \
    -e CRYPTO_FUNDS_EXPORTER_BINANCE_KEY=... \
    -e CRYPTO_FUNDS_EXPORTER_BINANCE_SECRET=... \
    -e CRYPTO_FUNDS_EXPORTER_KUCOIN_KEY=... \
    -e CRYPTO_FUNDS_EXPORTER_KUCOIN_SECRET=... \
    --name crypto-funds-exporter \    
    crypto-funds-exporter
```

## Endpoints

Getting metrics 

```bash
curl localhost:9518/metrics
```

Checking server alive

```bash
curl localhost:9518/ping 
```

## Example Prometheus config

```yaml
global:
  scrape_interval: 5s

scrape_configs:
  - job_name: funds
    honor_labels: true
    static_configs:
      - targets:
          - 'localhost:9518'
```
