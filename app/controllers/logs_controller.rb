# frozen_string_literal: true

class LogsController < ApplicationController
  skip_before_action :require_login, only: [:index, :show], raise: false
  before_action :set_log, only: [:show, :edit, :update, :destroy]

  def index
    @q = Log.includes(:user).ransack(params[:q])
    @logs = @q.result(distinct: true).page(params[:page])
  end

  def show
  end

  def new
    @log = Log.new
  end

  def create
    @log = current_user.logs.build(log_prams)
    if @log.save
      redirect_to log_path(@log), notice: "#{@log.title}を作成しました。"
    else
      render :new
    end
  end

  def edit
    unless @log.user == current_user
      redirect_to root_path, alert: ["このログの変更権限がありません。"]
    end
  end

  def update
    if @log.update(log_prams)
      redirect_to log_path(@log), notice: "#{@log.title}を更新しました。"
    else
      render :edit
    end
  end

  def destroy
    @log.destroy
    redirect_to logs_path, notice: "#{@log.title}を削除しました。"
  end

  private
    def set_log
      @log = Log.find_by!(id: params[:id])
    end

    def log_prams
      params.require(:log).permit(:title, :description, :color, :graph)
    end
end
