############################ FINDING 2'S COMPLEMENT OF A BINARY NUMBER ############################################

def twos_comp(val,integer_precision,fraction_precision):
    flipped = ''.join(str(1-int(x))for x in val)
    length = '0' + str(integer_precision+fraction_precision) + 'b'
    bin_literal = format((int(flipped,2)+1),length)
    return bin_literal
#print(type(twos_comp('01101011000',8,7)))
############################ FINDING 2'S COMPLEMENT OF A BINARY NUMBER ############################################


############################ CONVERTING FLOAT TO FIXED POINT ############################################


def float_to_bin(num,integer_precision,fraction_precision):
    if(num<0):
        sign_bit = 1
        num = -1*num
    else:
        sign_bit = 0
    precision = '0'+ str(integer_precision) + 'b'
    integral_part = format(int(num),precision)
    fractional_part_f = num - int(num)
    fractional_part = []
    for i in range(fraction_precision):
        d = fractional_part_f*2
        fractional_part_f = d -int(d)        
        fractional_part.append(int(d))
    fraction_string = ''.join(str(e) for e in fractional_part)
    if(sign_bit == 1):
        binary = str(sign_bit) + twos_comp(integral_part + fraction_string,integer_precision,fraction_precision)
    else:
        binary = str(sign_bit) + integral_part+fraction_string
    return str(binary)
############################ CONVERTING FLOAT TO FIXED POINT ############################################

############################ CONVERTING FIXED POINT TO FLOAT ############################################

def bin_to_float(s,integer_precision,fraction_precision):       #s = input binary string
    number = 0.0
    i = integer_precision - 1
    j = 1
    if(s[0] == '1'):
        s_complemented = twos_comp((s),integer_precision,fraction_precision)
    else:
        s_complemented = s
    while(j != integer_precision + fraction_precision):
        number += int(s_complemented[j])*(2**i)
        i -= 1
        j += 1
    print(number)
############################ CONVERTING FIXED POINT TO FLOAT ############################################