import sys
import os
import glob
import argparse

import yaml

sys.path.insert(1, os.path.abspath(os.path.dirname(os.path.abspath(__file__)) + "/../divebits_tools/"))
from DiveBits_base import DiveBits_base
from DiveBits_configstring import DiveBits_configstring


class HexInt(int):  # subtype definition to allow Hex YAML output
    pass


# BEGIN

if len(sys.argv) < 2:
    raise SyntaxError('Arguments missing')
tcl_args = sys.argv[1]
tcl_args = tcl_args.replace('{', '')
tcl_args = tcl_args.replace('}', '')

tcl_args = tcl_args.split()

# parse command-line arguments
parser = argparse.ArgumentParser(description='An example config file generator')

parser.add_argument('-t', '--tmpl_path', action='store', required=True,
                    dest="template_path", help='Path to template file directory')

parser.add_argument('-c', '--config_path', action='store', required=True,
                    dest="config_files_path", help='Output path for config files')

parser.add_argument('-n', '--num_files', action='store', required=False, type=int, default=8, choices=range(1, 256),
                    dest="number_of_files", help='Number of YAML config files to generate')

cl_args = parser.parse_args(tcl_args)

# USING THE YAML TEMPLATE. JSON WOULD BE POSSIBLE TOO
template_file_yaml = cl_args.template_path + "/db_template.yaml"
config_files_path = cl_args.config_files_path
file_count = cl_args.number_of_files

if not os.path.exists(template_file_yaml):
    raise SyntaxError("YAML Template file doesn't exist")

if not os.path.exists(config_files_path):
    raise SyntaxError("Output path for bitstream config files doesn't exist")

# remove old files
old_config_files = glob.glob(config_files_path + "/*.yaml")
old_config_files.extend(glob.glob(config_files_path + "/*.json"))
for f in old_config_files:
    os.remove(f)

#
# generation of example config files for DiveBits demo project
yaml.add_representer(HexInt, lambda dumper, repdata: yaml.ScalarNode('tag:yaml.org,2002:int', hex(repdata)))
for i in range(0, file_count):

    template_data = yaml.safe_load(open(template_file_yaml))
    components = template_data['db_components']
    # print(components)

    for component in components:
        component.pop("READONLY", None)
        block_path = component["BLOCK_PATH"]
        configurable = component["CONFIGURABLE"]

        if block_path == "/divebits_AXI_4_constant_registers_0":
            configurable["REGISTER_00_VALUE"] = HexInt(0xDB00000A + i*0x00000100)
            configurable["REGISTER_01_VALUE"] = HexInt(0xDB00000B + i*0x00000100)
            configurable["REGISTER_02_VALUE"] = HexInt(0xDB00000C + i*0x00000100)
            configurable["REGISTER_03_VALUE"] = HexInt(0xDB00000D + i*0x00000100)

        elif block_path == "/divebits_AXI_Master_WriteOnly_0":
            code: dict = {}
            codeword: dict = {}
            opcode_count = 0
            uartlite_addr = 0x40600000
            tx_fifo_offset = 0x4

            codeword = {"OPCODE": "SET_BASE_ADDR", "ADDR": HexInt(uartlite_addr)}
            code[opcode_count] = codeword.copy();
            opcode_count += 1

            to_print: str = "--- Hi from DiveBits AXI Master, Config " + ("%0.2Xh" % i) + " ---\r\n"
            for char in to_print:
                codeword = {"OPCODE": "WRITE_FROM_CODE", "ADDR": HexInt(tx_fifo_offset), "DATA": HexInt(ord(char))}
                code[opcode_count] = codeword.copy();
                opcode_count += 1

            configurable["OPCODE_COUNT"] = HexInt(opcode_count)
            configurable["CODE"] = code

        elif block_path == "/divebits_BlockRAM_init_0":
            configurable["default_value"] = HexInt(0xDB0000DB)

            words: dict = {}
            for addr in range(0, 8):
                words[HexInt(addr)] = HexInt(0xDB000000 + i*0x00010000 + addr)
            for addr in range(504, 512):
                words[HexInt(addr)] = HexInt(0xDB000000 + i*0x00010000 + addr)
            configurable["words"] = words

            range_1: dict = {"from":   HexInt(8), "to":  HexInt(15), "value": HexInt(0xDBDBDBDB)}
            range_2: dict = {"from": HexInt(496), "to": HexInt(503), "value": HexInt(0xDBDBDBDB)}
            configurable["ranges"] = [range_1, range_2]

        elif block_path == "/divebits_constant_vector_0":
            configurable["VALUE"] = HexInt(i % 8)

        elif block_path == "/divebits_constant_vector_1":
            configurable["VALUE"] = HexInt(8+(i % 8))

        else:  # other blocks, keep template data, or drop to loose configuration?
            components.remove(component)
            pass

    output_file_yaml = config_files_path + "/config_" + str(i) + ".yaml"
    output_file = open(output_file_yaml, 'w')
    yaml.dump(template_data, output_file, sort_keys=False)

print("DiveBits demo configurations written.")
