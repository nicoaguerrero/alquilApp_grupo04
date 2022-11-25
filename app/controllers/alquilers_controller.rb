class AlquilersController < ApplicationController

    before_action :set_cache_headers

    def show
        @vehiculo = Vehiculo.find(params[:id])
        @status = -1
        @alquiler = Alquiler.where(user_id: current_usuario.id).last
        if(@alquiler.status == "en_curso")
            @status = 0
        elsif (@alquiler.status == "completado")
            @status = 1
        elsif (@alquiler.status == "cancelado")
            @status = 3
        end
    end

    def finished
        @alquiler = Alquiler.where(user_id: current_usuario.id).last
        @alquiler.status = 1
        @alquiler.save

        redirect_to root_path, notice: "Alquiler finalizado con exito"
    end

    def destroy
        @alquiler = Alquiler.where(user_id: current_usuario.id).last
        current_usuario.billetera.saldo = current_usuario.billetera.saldo + 200*@alquiler.hours
        current_usuario.billetera.save
        
        @alquiler.status = 3
        @alquiler.save
        redirect_to root_path
    end

    def create
        @alquiler = Alquiler.new(alquiler_params)
        @alquiler.user_id = current_usuario.id
        @alquiler.vehicle_id = params[:vehicle_id]
        if ((current_usuario.billetera.saldo - 200*@alquiler.hours) >= 0)
            current_usuario.billetera.saldo = current_usuario.billetera.saldo - 200*@alquiler.hours
            current_usuario.billetera.save
            if @alquiler.save
                redirect_to estado_mi_estado_path
            end
        else
            redirect_to alquiler_path(@alquiler.vehicle_id), notice: "Fondos insuficientes"
        end
    end

    private

        def alquiler_params
            params.require(:alquiler).permit(:hours);
        end
end
