module hex

const(
	hex_table = '0123456789abcdef'
	invalid_length_error = error('Hexadecimal string must be an even amount of characters.')
)

// error returns an invalid byte error
fn invalid_byte_error(b byte) IError {
	return error('Hexadecimal string can only contain the characters \'$hex_table\'. Provided byte: $b')
}

// encode_len returns the length of an encoding of n source bytes.
fn encode_len(n int) int { return n *2 }

// encode encodes `input` into hexadecimal byte array
// and returns encoded array + length
pub fn encode(input []byte) ([]byte, int) {
	mut dst := []byte{len: encode_len(input.len)}
	mut i := 0
	for v in input {
		dst[i] = hex_table[v >> 4]
		dst[i+1] = hex_table[v & 0x0f]
		i += 2
	}

	return dst, dst.len
}

// encode_str_upper encodes `input` into a hexadecimal string and
// converts the characerts 'a' through 'f' to uppercase.
pub fn encode_str_upper(input string) string {
	return encode_str(input).to_upper()
}

// encode_str encodes `input` into hexadecimal string and returns it
pub fn encode_str(input string) string {
	barr, _ := encode(input.bytes())
	return barr.bytestr()
}

// decode_len returns the length of a decoding of `len` source bytes.
fn decode_len(len int) int { return len / 2 }

// decode decodes `input` into `input.len / 2` bytes.
// Returns the decoded string and the actual
// number of bytes written to string.
pub fn decode(input []byte) ?([]byte, int) {
	mut dst := []byte{len: decode_len(input.len)}
	mut i, mut j := 0, 1
	for ; j < input.len; j += 2 {
		a := from_hex_char(input[j-1]) or {
			return err
		}
		b := from_hex_char(input[j]) or {
			return err
		}

		dst[i] = (a << 4) | b
		i++
	}

	if input.len % 2 == 1{
		_ := from_hex_char(input[j-1]) or {
			return err
		}

		return invalid_length_error
	}

	return dst, i
}

// decode decodes `input` into ASCII string and returns it
pub fn decode_str(input string) ?string {
	barr, _ := decode(input.bytes()) or {
		return err
	}
	return barr.bytestr()
}

// from_hex_char converts a hexadecimal character into its value
fn from_hex_char(b byte) ?byte {
	match b {
		`0`...`9` { return byte(b - `0`) }
		`a`...`f` { return byte(b - `a` + 10) }
		`A`...`F` { return byte(b - `A` + 10) }
		else { return invalid_byte_error(b) }
	}
}
