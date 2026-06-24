# --- CONFIGURACAO OBRIGATORIA ---
# Altere este caminho para a sua pasta de instalacao do Quartus.
set QUARTUS_ROOT "C:/intelFPGA_lite/18.1/quartus"
transcript on

puts "Criando bibliotecas..."
vlib work
vlib altera_mf_lib
vmap altera_mf ./altera_mf_lib

puts "Compilando bibliotecas de simulacao da Altera..."
vlog -work altera_mf_lib "$QUARTUS_ROOT/eda/sim_lib/altera_mf.v"

# Define o diretorio para includes (para o Definitions.v)
set INCDIR "+incdir+."

puts "Compilando o design..."
# Componentes do Datapath
vlog -work work $INCDIR ArithmeticLogicUnit.v
vlog -work work $INCDIR ProgramCounter.v
vlog -work work $INCDIR RegisterBank.v
vlog -work work $INCDIR Datapath.v
vlog -work work $INCDIR ControlUnit.v
vlog -work work ProgramROM.v 
vlog -work work ValuesRAM.v 
vlog -work work TinyCore8.v
vlog -work work TinyCore8TB.v


puts "Iniciando a simulacao..."
vsim -L altera_mf work.TinyCore8TB
configure wave -timelineunits ns

puts "Configurando a janela Wave..."
# Sinais Globais
add wave -divider "TinyCore8"
add wave -radix binary /TinyCore8TB/RST
add wave -radix binary -color purple /TinyCore8TB/CLK
add wave -radix decimal /TinyCore8TB/REGA
add wave -radix decimal /TinyCore8TB/REGB

# Sinais da ControlUnit
add wave -divider "ControlUnit"
add wave -radix hex -color yellow /TinyCore8TB/uut/b2v_inst1/state
add wave -radix binary -color cyan /TinyCore8TB/uut/b2v_inst1/instruction
add wave -radix binary -color CornflowerBlue /TinyCore8TB/uut/b2v_inst1/opcode
add wave -radix binary -color MediumBlue /TinyCore8TB/uut/b2v_inst1/instructionRegister
add wave -radix binary /TinyCore8TB/uut/b2v_inst1/pcIncEnable
add wave -radix binary /TinyCore8TB/uut/b2v_inst1/pcLoadEnable
add wave -radix binary /TinyCore8TB/uut/b2v_inst1/ramWriteEnable

# Sinais do Datapath
add wave -divider "Datapath"
add wave -radix hex /TinyCore8TB/uut/b2v_datapathInst/immediateValue
add wave -radix binary /TinyCore8TB/uut/b2v_datapathInst/aluSelector
add wave -radix decimal /TinyCore8TB/uut/b2v_datapathInst/aluInst/in1
add wave -radix decimal /TinyCore8TB/uut/b2v_datapathInst/aluInst/in2
add wave -radix decimal /TinyCore8TB/uut/b2v_datapathInst/aluOutResult
add wave -radix binary /TinyCore8TB/uut/b2v_datapathInst/regWriteEnableA
add wave -radix binary /TinyCore8TB/uut/b2v_datapathInst/regAInMuxSel
add wave -radix binary /TinyCore8TB/uut/b2v_datapathInst/regWriteEnableB
add wave -radix binary /TinyCore8TB/uut/b2v_datapathInst/regBInMuxSel
add wave -radix binary /TinyCore8TB/uut/b2v_datapathInst/aluIn2MuxSel
add wave -radix binary /TinyCore8TB/uut/b2v_datapathInst/ramInMuxSel

# Sinais das memorias:
add wave -divider "ValuesRAM"
add wave -radix decimal /TinyCore8TB/uut/b2v_inst/q
add wave -radix decimal -color orange /TinyCore8TB/uut/b2v_inst/address
add wave -radix decimal /TinyCore8TB/uut/b2v_inst/data
add wave -radix binary /TinyCore8TB/uut/b2v_inst/wren

add wave -divider "ProgramROM"
add wave -radix binary /TinyCore8TB/uut/b2v_inst2/q
add wave -radix decimal -color orange /TinyCore8TB/uut/b2v_inst2/address

puts "Executando simulacao..."
run -all
puts "Simulacao concluida."