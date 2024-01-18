require 'rails_helper'

RSpec.describe User, type: :model do
  it "has a valid factory" do
    expect(FactoryBot.build(:user)).to be_valid
  end

  it "is valid with a first name, last name and email, and password" do
    user = User.new(
      first_name: "Aaron",
      last_name:  "Sumner",
      email:      "tester@example.com",
      password:   "dottle-nouveau-pavilion-tights-furze",
    )
    expect(user).to be_valid
  end

  it { is_expected.to validate_presence_of :first_name }
  it { is_expected.to validate_presence_of :last_name }
  it { is_expected.to validate_presence_of :email }
  it { is_expected.to validate_uniqueness_of(:email).case_insensitive }

  it "is invalid without a first name" do
    user = User.new(first_name: nil)
    user.valid?
    expect(user.errors[:first_name]).to include("can't be blank")
  end

  it "returns a user's full name as a string" do
    user = FactoryBot.build(:user, first_name: "John", last_name: "Doe")
    expect(user.name).to eq "John Doe"
  end

  #factorybot使わないバージョン
  it "returns a user's full name as a string" do
    user = User.new(
      first_name: "John",
      last_name: "Doe",
      email: "johndoe@example.com",
    )
    expect(user.name).to eq "John Doe"
  end

  # 重複したメールアドレスなら無効な状態であること
  it "is invalid with a duplicate email address" do
    User.create(
      first_name:  "Joe",
      last_name:  "Tester",
      email:      "tester@example.com",
      password:   "dottle-nouveau-pavilion-tights-furze",
    )

    user = User.new(
      first_name:  "Jane",
      last_name:  "Tester",
      email:      "tester@example.com",
      password:   "dottle-nouveau-pavilion-tights-furze",
    )
    user.valid?
    expect(user.errors[:email]).to include("has already been taken")
  end

  it "sends a welcome email on account creation" do
    allow(UserMailer).to \
      receive_message_chain(:welcome_email, :deliver_later)
    user = FactoryBot.create(:user)
    expect(UserMailer).to have_received(:welcome_email).with(user)
  end

  it "performs geocoding", vcr: true do
    user = FactoryBot.create(:user, last_sign_in_ip: "161.185.207.20")
    expect {
      user.geocode
    }.to change(user, :location).
      from(nil).
      to("Brooklyn, New York, US")
  end
end
