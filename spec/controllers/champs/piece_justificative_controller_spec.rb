require 'spec_helper'

describe Champs::PieceJustificativeController, type: :controller do
  let(:user) { create(:user) }
  let(:procedure) { create(:procedure, :published, :with_piece_justificative) }
  let(:dossier) { create(:dossier, user: user, procedure: procedure) }

  describe '#show' do
    subject do
      get :show, params: params, format: 'js'
    end

    context 'when user is connected' do
      render_views
      before { sign_in user }

      let(:params) do
        {
          position: '1',
          champ_id: dossier.champs.first.id
         }
      end

      context 'when the champ exists' do
        it 'renders the champ name' do
          subject
          expect(response.body).to include('editable-champ-piece_justificative')
          expect(response.body).to include('dossier[champs_attributes][0][id]')
        end
      end
    end
  end
end
