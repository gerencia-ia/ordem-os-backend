# require 'rails_helper'
# require 'swagger_helper'

# RSpec.describe 'Clientes API', type: :request, swagger_doc: 'v1/swagger.yaml' do
#   path '/api/v1/clientes/{id}' do
#     parameter name: :id,
#               in: :path,
#               type: :integer,
#               description: 'ID do cliente'

#     get 'Busca um cliente' do
#       tags 'Clientes'

#       produces 'application/json'

#       response '200', 'Cliente encontrado' do
#         let!(:cliente) do
#           Cliente.create!(
#             nome: 'João da Silva',
#             email: 'joao@email.com',
#             enderecos_attributes: [
#               cidade: 'Cidade Exemplo',
#               rua: 'Rua Exemplo',
#               numero: '123',
#               bairro: 'Bairro Exemplo',
#               complemento: 'Complemento Exemplo'
#             ],
#             telefones_attributes: [
#               numero: '11999999999'
#             ]
#         )
#         end

#         let(:id) { cliente.id }

#         run_test!
#       end

#       response '404', 'Cliente não encontrado' do
#         let(:id) { 999999 }

#         run_test!
#       end
#     end
#   end
# end
