class Backoffice::DossiersController < ApplicationController
  include SmartListing::Helper::ControllerExtensions
  helper SmartListing::Helper

  before_action :authenticate_gestionnaire!

  def index
    smartlisting_dossier (params[:liste] || 'a_traiter')
  end

  def show
    create_dossier_facade params[:id]
    @champs = @facade.champs_private unless @facade.nil?
  end

  def download_dossiers_tps
    dossiers = current_gestionnaire.dossiers.where.not(state: :draft)

    response.headers['Content-Type'] = 'text/csv'

    render csv: dossiers, status: 200
  end

  def search
    @search_terms = params[:q]
    @dossiers_search, @dossier = Dossier.search(current_gestionnaire, @search_terms)

    create_dossiers_list_facade

    unless @dossiers_search.empty?
      @dossiers_search = @dossiers_search.paginate(:page => params[:page]).decorate
    end

    @dossier = @dossier.decorate unless @dossier.nil?

  rescue RuntimeError
    @dossiers_search = []
  end

  def valid
    create_dossier_facade params[:dossier_id]

    @facade.dossier.next_step! 'gestionnaire', 'valid'
    flash.notice = 'Dossier confirmé avec succès.'

    NotificationMailer.dossier_validated(@facade.dossier).deliver_now!

    render 'show'
  end

  def close
    create_dossier_facade params[:dossier_id]

    @facade.dossier.next_step! 'gestionnaire', 'close'
    flash.notice = 'Dossier traité avec succès.'

    render 'show'
  end

  def follow
    follow = current_gestionnaire.toggle_follow_dossier params[:dossier_id]

    flash.notice = (follow.class == Follow ? 'Dossier suivi' : 'Dossier relaché')
    redirect_to request.referer
  end

  def reload_smartlisting
    begin
      @liste = URI(request.referer).query.split('=').second
    rescue NoMethodError
      @liste = 'a_traiter'
    end

    smartlisting_dossier @liste

    render 'backoffice/dossiers/index', formats: :js
  end

  private

  def smartlisting_dossier liste
    create_dossiers_list_facade liste

    @dossiers = smart_listing_create :dossiers,
                                     @dossiers_list_facade.dossiers_to_display,
                                     partial: "backoffice/dossiers/list",
                                     array: true
  end

  def create_dossiers_list_facade liste='a_traiter'
    @dossiers_list_facade = DossiersListFacades.new current_gestionnaire, liste
  end

  def create_dossier_facade dossier_id
    @facade = DossierFacades.new dossier_id, current_gestionnaire.email

  rescue ActiveRecord::RecordNotFound
    flash.alert = t('errors.messages.dossier_not_found')
    redirect_to url_for(controller: '/backoffice')
  end
end
