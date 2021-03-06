import DiveBits_base
from DiveBits_base import db_bitwidths
from bitstring import BitArray


class divebits_4_constant_vectors(DiveBits_base.DiveBits_base):

    def num_configbits(self) -> int:

        bitcount = super().num_configbits()

        db_vector_width = self.db_component["DB_VECTOR_WIDTH"]
        if db_vector_width != 0:
            bitcount += (db_bitwidths["LENGTH"] + db_bitwidths["ADDRESS"] + db_bitwidths["CHANNEL"]) * 4
            bitcount += (db_vector_width * 4)
            return bitcount
        else:
            raise SyntaxError('DB_VECTOR_WIDTH is 0')

    def generate_component_template(self) -> dict:

        temp_comp = super().generate_component_template() #cut argument self.db_component

        temp_comp["READONLY"]["DB_VECTOR_WIDTH"] = self.db_component["DB_VECTOR_WIDTH"]
        db_default_value = self.db_component["DB_DEFAULT_VALUE_ALL"]
        for i in range(0, 4):
            temp_comp["CONFIGURABLE"]["VALUE_" + f'{i:02d}'] = \
                self.db_component["DB_DEFAULT_VALUE_" + f'{i:02d}'] + db_default_value

        return temp_comp

    def generate_config_bitstring(self, config_list) -> BitArray:

        configbits = BitArray(0)
        if not super().find_block_config(config_list):
            return configbits

        db_vector_width = self.db_component["DB_VECTOR_WIDTH"]
        for i in range(0, 4):
            if ("VALUE_" + f'{i:02d}') in self.block_config["CONFIGURABLE"]:
                value = self.block_config["CONFIGURABLE"]["VALUE_" + f'{i:02d}']
                configbits.prepend(BitArray(uint=i, length=db_bitwidths["CHANNEL"]))
                configbits.prepend(BitArray(uint=self.db_address, length=db_bitwidths["ADDRESS"]))
                configbits.prepend(BitArray(uint=db_vector_width, length=db_bitwidths["LENGTH"]))
                configbits.prepend(BitArray(uint=value, length=db_vector_width))

        return configbits

