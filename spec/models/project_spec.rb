require 'rails_helper'

RSpec.describe Project, type: :model do
  it { is_expected.to validate_uniqueness_of(:name).scoped_to(:user_id) }

  describe "late status" do
    it "is late when the due date is past today" do
      project = FactoryBot.create(:project, :due_yesterday)
      expect(project).to be_late
    end

    it "is on time when the due date is today" do
      project = FactoryBot.create(:project, :due_today)
      expect(project).to_not be_late
    end

    it "is on time when the due date is in the future" do
      project = FactoryBot.create(:project, :due_tomorrow)
      expect(project).to_not be_late
    end
  end

  it "can have many notes" do
    project = FactoryBot.create(:project, :with_notes)
    expect(project.notes.length).to eq 5
  end

  #3章演習/projectモデルのバリデーションテスト
  it "is valid with a name" do
      user = FactoryBot.create(:user)
      project = FactoryBot.create(:project, owner: user, name: "Project_name")
    expect(project).to be_valid
  end

  it "is invalid with a name" do
    project = Project.new(name: nil)
    project.valid?
    expect(project.errors[:name]).to include("can't be blank")
  end

  # ユーザー単位では重複したプロジェクト名を許可しないこと
  it "does not allow duplicate project names per user" do
    user = FactoryBot.create(:user)
    user.projects.create(
      name: "Test Project",
    )
    new_project = user.projects.build(
      name: "Test Project",
    )
    new_project.valid?
    expect(new_project.errors[:name]).to include("has already been taken")
  end

  it "allows two users to share a project name" do
    user = FactoryBot.create(:user)
    user.projects.create(
      name: "Test Project",
    )

    other_user = User.create(
      first_name: "Jane",
      last_name: "Tester",
      email: "janetester@example.com",
      password: "dottle-nouveau-pavilion-tights-furze",
      )

    other_project  = other_user.projects.build(
      name: "Test Project",
    )

    expect(other_project).to be_valid
  end
end
