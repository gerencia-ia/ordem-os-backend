require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "password must have at least six characters" do
    user = User.new(cpf: "98765432100", role: Role.new(nome: "Técnico"), password: "12345")

    assert_not user.valid?
    assert_includes user.errors[:password], "is too short (minimum is 6 characters)"
  end

  test "password with six characters is valid" do
    user = User.new(cpf: "98765432101", role: Role.new(nome: "Técnico"), password: "123456")

    assert user.valid?, user.errors.full_messages.to_sentence
  end
end
