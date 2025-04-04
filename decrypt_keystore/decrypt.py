import json
import argparse
from binascii import unhexlify
from Crypto.Cipher import AES
from Crypto.Protocol.KDF import PBKDF2
from Crypto.Hash import SHA256, keccak
from Crypto.Util import Counter
from hashlib import sha256

def diagnose_keystore(file_path: str, password: str):
    with open(file_path, "r") as f:
        keystore = json.load(f)

    print(f"🔍 Diagnosing keystore: {file_path}")

    for address, data in keystore.get("credentials", {}).items():
        print(f"\n🔐 Address: {address}")
        try:
            crypto = data["crypto"]
            salt = unhexlify(crypto["kdfparams"]["salt"])
            iterations = crypto["kdfparams"]["c"]
            ciphertext = unhexlify(crypto["ciphertext"])
            iv = unhexlify(crypto["cipherparams"]["iv"])
            mac_expected = unhexlify(crypto["mac"])

            # Derive key
            derived_key = PBKDF2(password, salt, dkLen=32, count=iterations, hmac_hash_module=SHA256)

            # Ethereum-style MAC
            keccak_hash = keccak.new(digest_bits=256)
            keccak_hash.update(derived_key[16:32] + ciphertext)
            mac_computed = keccak_hash.digest()

            if mac_computed == mac_expected:
                print("✅ MAC matched using keccak256.")
            else:
                print("❌ MAC failed with keccak256. Trying SHA256 fallback...")
                fallback_mac = sha256(derived_key[:16] + ciphertext).digest()
                if fallback_mac == mac_expected:
                    print("✅ MAC matched using SHA256 fallback.")
                else:
                    print("❌ MAC failed with both keccak256 and SHA256.")
                    return

            # Decrypt
            ctr = Counter.new(128, initial_value=int.from_bytes(iv, byteorder="big"))
            cipher = AES.new(derived_key[:16], AES.MODE_CTR, counter=ctr)
            decrypted = cipher.decrypt(ciphertext)

            print(f"\n🧪 Raw Decrypted (hex): {decrypted.hex()}")
            try:
                utf8 = decrypted.decode("utf-8")
                print("\n📜 Decrypted as UTF-8 string:")
                print(utf8)

                try:
                    parsed = json.loads(utf8)
                    print("\n🧾 Decrypted as JSON:")
                    print(json.dumps(parsed, indent=2))
                except Exception as e:
                    print("⚠️ Could not parse UTF-8 string as JSON:", e)

            except Exception as e:
                print("⚠️ Could not decode decrypted data as UTF-8:", e)

        except Exception as e:
            print(f"💥 Error: {e}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Diagnose Waku-style keystore files.")
    parser.add_argument("--file", required=True, help="Path to keystore JSON file")
    parser.add_argument("--password", required=True, help="Password to decrypt")

    args = parser.parse_args()
    diagnose_keystore(args.file, args.password)