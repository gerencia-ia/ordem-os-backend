# frozen_string_literal: true

puts "Criando ordens de serviço..."

# ============================================================
# BUSCAR DADOS NECESSÁRIOS
# ============================================================

cliente_1 = Cliente.find_by!(
  email: "cliente.demo@example.com"
)

cliente_2 = Cliente.find_by!(
  email: "empresa@example.com"
)

endereco_1 = cliente_1.enderecos.first!
endereco_2 = cliente_2.enderecos.first!

equipamento_1 = Equipamento.find_by!(
  cliente: cliente_1,
  marca: "Samsung"
)

equipamento_2 = Equipamento.find_by!(
  cliente: cliente_2,
  marca: "LG"
)

tecnico_1 = Tecnico.find_by!(
  cpf: "33333333333"
)

tecnico_2 = Tecnico.find_by!(
  cpf: "44444444444"
)

status_aberta = Status.find_by!(
  nome: "Aberta"
)

status_andamento = Status.find_by!(
  nome: "Em andamento"
)

prioridade_media = Prioridade.find_by!(
  descricao: "Média"
)

prioridade_alta = Prioridade.find_by!(
  descricao: "Alta"
)

servico_manutencao = Servico.find_by!(
  nome: "Manutenção preventiva"
)

servico_reparo = Servico.find_by!(
  nome: "Reparo de ar-condicionado"
)

# ============================================================
# ORDEM DE SERVIÇO 1
# ============================================================

ordem_1 = OrdemServico.find_or_create_by!(
  numero_ordem: "OS-000001"
) do |os|
  os.cliente = cliente_1
  os.endereco = endereco_1
  os.status = status_aberta
  os.prioridade = prioridade_media

  os.data_agendamento = 2.days.from_now
  os.data_vencimento = 5.days.from_now.to_date

  os.descricao = "Manutenção preventiva do ar-condicionado."
  os.observacao = "Cliente solicitou atendimento no período da manhã."
  os.tipo_servico = "Manutenção"

  os.custo_estimado = 180.00
  os.valor_total = 180.00
end

# ============================================================
# ORDEM DE SERVIÇO 2
# ============================================================

ordem_2 = OrdemServico.find_or_create_by!(
  numero_ordem: "OS-000002"
) do |os|
  os.cliente = cliente_2
  os.endereco = endereco_2
  os.status = status_andamento
  os.prioridade = prioridade_alta

  os.data_agendamento = 1.day.from_now
  os.data_vencimento = 3.days.from_now.to_date

  os.descricao = "Equipamento não está resfriando corretamente."
  os.observacao = "Verificar compressor e gás refrigerante."
  os.tipo_servico = "Reparo"

  os.custo_estimado = 250.00
  os.valor_total = 250.00
end

# ============================================================
# OS_SERVICOS
# ============================================================

OsServico.find_or_create_by!(
  ordem_servico: ordem_1,
  servico: servico_manutencao
) do |os_servico|
  os_servico.quantidade = 1
end

OsServico.find_or_create_by!(
  ordem_servico: ordem_2,
  servico: servico_reparo
) do |os_servico|
  os_servico.quantidade = 1
end

# ============================================================
# OS_EQUIPAMENTOS
# ============================================================

OsEquipamento.find_or_create_by!(
  ordem_servico: ordem_1,
  equipamento: equipamento_1
) do |os_equipamento|
  os_equipamento.laudo =
    "Equipamento necessita de limpeza preventiva."
end

OsEquipamento.find_or_create_by!(
  ordem_servico: ordem_2,
  equipamento: equipamento_2
) do |os_equipamento|
  os_equipamento.laudo =
    "Equipamento apresenta baixo rendimento."
end

# ============================================================
# OS_TECNICOS
# ============================================================

OsTecnico.find_or_create_by!(
  ordem_servico: ordem_1,
  tecnico: tecnico_1
)

OsTecnico.find_or_create_by!(
  ordem_servico: ordem_2,
  tecnico: tecnico_2
)

# ============================================================
# TAREFAS
# ============================================================

Tarefa.find_or_create_by!(
  ordem_servico: ordem_1,
  descricao: "Realizar limpeza do equipamento"
) do |tarefa|
  tarefa.status = "nao_iniciada"
  tarefa.tecnico = tecnico_1
end

Tarefa.find_or_create_by!(
  ordem_servico: ordem_1,
  descricao: "Verificar funcionamento"
) do |tarefa|
  tarefa.status = "nao_iniciada"
  tarefa.tecnico = tecnico_1
end

Tarefa.find_or_create_by!(
  ordem_servico: ordem_2,
  descricao: "Diagnosticar falha no equipamento"
) do |tarefa|
  tarefa.status = "em_andamento"
  tarefa.tecnico = tecnico_2
  tarefa.data_inicio = Time.current
end

puts "✓ Ordens de serviço: #{OrdemServico.count}"
puts "✓ Serviços das OS: #{OsServico.count}"
puts "✓ Equipamentos das OS: #{OsEquipamento.count}"
puts "✓ Técnicos das OS: #{OsTecnico.count}"
puts "✓ Tarefas: #{Tarefa.count}"
