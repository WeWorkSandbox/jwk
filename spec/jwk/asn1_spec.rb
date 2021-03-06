describe JWK::ASN1 do
  describe '.rsa_public_key' do
    let(:known_asn) do
      Base64.decode64('MBowDQYJKoZIhvcNAQEBBQADCQAwBgIBAQIBAg==')
    end

    let(:bignum) do
      ([0x80FFFFFF] * 56).inject(0) { |a, n| (a << 32) | n }
    end

    let(:known_big_asn) do
      Base64.decode64('MIH9MA0GCSqGSIb3DQEBAQUAA4HrADCB5wIBAQKB4QCA////gP///4D///+A
                       ////gP///4D///+A////gP///4D///+A////gP///4D///+A////gP///4D/
                       //+A////gP///4D///+A////gP///4D///+A////gP///4D///+A////gP//
                       /4D///+A////gP///4D///+A////gP///4D///+A////gP///4D///+A////
                       gP///4D///+A////gP///4D///+A////gP///4D///+A////gP///4D///+A
                       ////gP///4D///+A////gP///4D///+A////gP///w==')
    end

    it 'generates valid ASN1 for a Generic Public Key of type RSA' do
      result = JWK::ASN1.rsa_public_key(1, 2)
      expect(result).to eq(known_asn)
    end

    it 'handles big values numbers correctly' do
      result = JWK::ASN1.rsa_public_key(1, bignum)
      expect(result).to eq(known_big_asn)
    end
  end

  describe '.rsa_private_key' do
    let(:known_asn) do
      Base64.decode64('MBwCAQACAQECAQICAQMCAQQCAQUCAQYCAQcCAgCA')
    end

    it 'generates valid ASN1 for an RSA Private Key' do
      result = JWK::ASN1.rsa_private_key(1, 2, 3, 4, 5, 6, 7, 0x80)
      expect(result).to eq(known_asn)
    end
  end

  describe '.ec_private_key' do
    let(:known_p256_asn) do
      Base64.decode64('MFgCAQEEAaCgCgYIKoZIzj0DAQehRANCAAQAAAAAAAAAAAAAAAAAAAAA' \
                      'AAAAAAAAAAAAAAAAAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' \
                      'AAAAAAAD')
    end

    let(:known_p384_asn) do
      Base64.decode64('MHUCAQEEAaCgBwYFK4EEACKhZANiAAQAAAAAAAAAAAAAAAAAAAAAAAAA' \
                      'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIAAAAAAAAAAAAAAAAA' \
                      'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAM=')
    end

    let(:known_p521_asn) do
      Base64.decode64('MIGXAgEBBAGgoAcGBSuBBAAjoYGFA4GCAAQAAAAAAAAAAAAAAAAAAAAA' \
                      'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' \
                      'AAAAAAACAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' \
                      'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAw==')
    end

    def pad_coord_for_crv(crv, coord)
      coord.rjust(JWK::ECKey::COORD_SIZE[crv], "\x00")
    end

    def raw_public_key(crv, x, y)
      raw_x = JWK::Utils.int_to_binary(x)
      raw_y = JWK::Utils.int_to_binary(y)

      raw_x = pad_coord_for_crv(crv, raw_x)
      raw_y = pad_coord_for_crv(crv, raw_y)

      "\x04#{raw_x}#{raw_y}"
    end

    it 'generates valid ASN1 for a P-256 EC Private Key' do
      result = JWK::ASN1.ec_private_key('P-256', 0xA0, raw_public_key('P-256', 2, 3))
      expect(result).to eq(known_p256_asn)
    end

    it 'generates valid ASN1 for a P-384 EC Private Key' do
      result = JWK::ASN1.ec_private_key('P-384', 0xA0, raw_public_key('P-384', 2, 3))
      expect(result).to eq(known_p384_asn)
    end

    it 'generates valid ASN1 for a P-521 EC Private Key' do
      result = JWK::ASN1.ec_private_key('P-521', 0xA0, raw_public_key('P-521', 2, 3))
      expect(result).to eq(known_p521_asn)
    end
  end
end
