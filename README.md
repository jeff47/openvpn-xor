# OpenVPN for Docker with XOR Obfuscation
This is a standard OpenVPN server in a Docker container complete with an EasyRSA PKI CA, based on [Kyle Manna's image](https://github.com/kylemanna/docker-openvpn), but
with the XOR obfuscation patches developed by Tunnelblick.

## Quick Start
1. Create a directory to hold your configuration files and keys.
2. Create a docker-compose.yml entry, mounting this directory to /etc/openvpn.  (The included model)
3. Initialize the configuration filesand certificates.  The container will prompt for a passphrase to protect the
  private key used by the newly generated certificate authority.

      ```
      % docker compose run --rm openvpnd ovpn_genconfig -u udp://VPN.SERVERNAME.COM
      % docker compose run --rm -it openvpnd ovpn_initpki
      ```
4. Start OpenVPN server process

      ```
      % docker compose up -d openvpnd
      ```

5. Generate a client certificate without a passphrase

      ```
      % docker compose run --rm -it openvpnd easyrsa build-client-full CLIENTNAME nopass
      ```
      
6. Retrieve the client configuration with embedded certificates

       ```
       % docker compose run --rm openvpnd ovpn_getclient CLIENTNAME > CLIENTNAME.ovpn
       ```
