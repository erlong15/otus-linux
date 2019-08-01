# Linux Administrations Course

## HW #1 - Linux Basics

- Скачиваем Linux kernel

  ```bash
  $ yum install wget -y && \
    mkdir /opt/kernel && cd /opt/kernel && \
    wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.2.5.tar.xz
  ```

- Распаковываем

  ```bash
  $ unxz -v linux-5.2.5.tar.xz
  ```

- Верифицируем скачанное ядро с помошью PGP

  ```bash
  $ wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.2.5.tar.sign && \
    gpg --verify linux-5.2.5.tar.sign
  ```

  <details><summary>Подробнее</summary><p>
  
  ```bash
  --2019-07-31 21:22:45--  https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.2.5.tar.sign
  Resolving cdn.kernel.org (cdn.kernel.org)... 151.101.1.176, 151.101.65.176, 151.101.129.176, ...
  Connecting to cdn.kernel.org (cdn.kernel.org)|151.101.1.176|:443... connected.
  HTTP request sent, awaiting response... 200 OK
  Length: 987 [text/plain]
  Saving to: ‘linux-5.2.5.tar.sign’

  100%  [================================================================================================ =============================================================>] 987         --.-K/s   in 0s

  2019-07-31 21:22:45 (6.00 MB/s) - ‘linux-5.2.5.tar.sign’ saved [987/987]

  gpg: Signature made Wed 31 Jul 2019 05:26:53 AM UTC using RSA key ID 6092693E
  gpg: Can't check signature: No public key
  ```
  </p></details>

  ```bash
  $ gpg --recv-keys 79BE3E4300411886
  ```

  <details><summary>Подробнее</summary><p>
  
  ```bash
  gpg: requesting key 6092693E from hkp server keys.gnupg.net
  gpg: key 6092693E: public key "Greg Kroah-Hartman (Linux kernel stable release signing key)   <greg@kroah.com>" imported
  gpg: key 6092693E: public key "Totally Legit Signing Key <mallory@example.org>" imported
  gpg: key 6092693E: public key "Greg Kroah-Hartman <gregkh@linuxfoundation.org>" imported
  gpg: no ultimately trusted keys found
  gpg: Total number processed: 3
  gpg:               imported: 3  (RSA: 3)
  ```
  </p></details>

    ```bash
  $ gpg --verify linux-5.2.5.tar.sign
  ```

  <details><summary>Подробнее</summary><p>
  
  ```bash
  gpg: Signature made Wed 31 Jul 2019 05:26:53 AM UTC using RSA key ID 6092693E
  gpg: Good signature from "Greg Kroah-Hartman <gregkh@linuxfoundation.org>"
  gpg:                 aka "Greg Kroah-Hartman <gregkh@kernel.org>"
  gpg:                 aka "Greg Kroah-Hartman (Linux kernel stable release signing key)  <greg@kroah.com>"
  gpg: WARNING: This key is not certified with a trusted signature!
  gpg:          There is no indication that the signature belongs to the owner.
  Primary key fingerprint: 647F 2865 4894 E3BD 4571  99BE 38DB BDC8 6092 693E
  ```
  </p></details>

- Распаковываем верифицированный архив

  ```bash
  $ tar xvf linux-5.2.5.tar && linux-5.2.5
  ```

- Копируем текущею конфигурацию ядра

  ```bash
  $ cp -v /boot/config-$(uname -r) .config
  ```
 
 <details><summary>Подробнее</summary><p>
  
  ```bash
  ‘/boot/config-3.10.0-957.12.2.el7.x86_64’ -> ‘.config’
  ```
  </p></details>

- Устанавливаем нужные зависимости

  ```bash
  $ yum group install -y "Development Tools"
  $ yum install -y ncurses-devel bison flex elfutils-libelf-devel openssl-devel bc
  ```

- Собираем и устанавливам новое ядро и модули ядра

  ```bash
  $ make oldconfig && make -j $(nproc) && make install && make modules_install
  ```

 <details><summary>Результирующие файлы</summary><p>
  
  [yum.log](homeworks/hw-001/yum.log)

  [.config](homeworks/hw-001/config)

  </p></details>

