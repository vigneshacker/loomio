require 'rails_helper'
describe API::InvitablesController do

  let(:user) { create :user }
  let(:contact_named_biff) { create :contact, user: user, name: "Biff Boink" }
  let(:contact_named_bang) { create :contact, user: user, name: "Bang Wharf" }
  let(:user_named_biff) { create :user, name: "Biff Bones" }
  let(:user_named_bang) { create :user, name: "Bang Whamfist" }
  let(:alien_named_biff) { create :user, name: "Biff Beef" }
  let(:group) { create :group }
  let(:group_named_biff) { create :group, name: "Biff Arang" }
  let(:group_named_bang) { create :group, name: "Bang Arang" }
  let(:hidden_named_biff) { create :group, name: "Biff Ahoy" }

  before do
    stub_request(:post, "http://localhost:9292/faye").to_return(status: 200)
    group.admins << user
    group.users  << user_named_biff
    group_named_biff.users << user
    group_named_bang.users << user
    sign_in user
  end

  describe 'index' do

    context 'success' do

      before do
        contact_named_biff; contact_named_bang; group_named_biff; group_named_bang;
      end

      it 'returns a users contacts filtered by query' do
        get :index, group_id: group.id, q: 'biff', format: :json
        json = JSON.parse(response.body)
        expect(json.keys).to include *(%w[invitables])
        ids_and_types = json['invitables'].map { |i| [i['id'], i['name']] }

        expect(ids_and_types).to include [contact_named_biff.id, contact_named_biff.name]
        expect(ids_and_types).to_not include [contact_named_bang.id, contact_named_bang.name]
      end

      it 'returns a users groups filtered by query' do
        get :index, group_id: group.id, q: 'biff', format: :json
        json = JSON.parse(response.body)
        expect(json.keys).to include *(%w[invitables])
        ids_and_types = json['invitables'].map { |i| [i['id'], i['name']] }

        expect(ids_and_types).to include [group_named_biff.id, group_named_biff.name]
        expect(ids_and_types).to_not include [group_named_bang.id, group_named_bang.name]
      end
    end

    context 'failure' do
      it 'does not allow access to an unauthorized group' do
        cant_see_me = create :group
        expect { get :index, group_id: cant_see_me.id, format: :json }.to raise_error CanCan::AccessDenied
      end
    end
  end

end
