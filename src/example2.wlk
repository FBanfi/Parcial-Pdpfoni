// Parcial Pdpfoni

// EMPRESA
object empresa {
	var property precioPorMB = 0
	var property precioPorSeg = 0
	var property precioBase = 0
	
}

// LINEA
class Linea {
	var telefono
	var packsActivos
	var consumosRealizados = []
	var tipoDeCliente
	
	method cantidadDeConsumos() = consumosRealizados.size()
	method todosLosConsumosEntre(fecha1, fecha2) {
		return consumosRealizados.filter({cons => cons.realizadoEntre(fecha1, fecha2)}).sum({cons => cons.costo()})
	}
	method costoPromedioDeConsumosEntre(fecha1, fecha2) {	// Puse con return y no "=" para que me entre de largo
		return self.todosLosConsumosEntre(fecha1, fecha2) / self.cantidadDeConsumos()
	}
	method costoConsumosRecientes() = self.todosLosConsumosEntre(new Date(), new Date().minusMonths(1))
	method comprarPack(unPack) {
		packsActivos.add(unPack)
	}
	method puedeHacer(consumo) {
		packsActivos.any({pack => pack.satisface(consumo)})
	}
	method realizar(consumo) {
		self.validarSiPuedeSatisfacerse(consumo)
		self.encontrarPackQueSatisfaga(consumo).aplicar(consumo)
		consumosRealizados.add(consumo)
	}
	method encontrarPackQueSatisfaga(consumo) = packsActivos.reverse().find({pack => pack.satisface(consumo)})
	method validarSiPuedeSatisfacerse(consumo) {
		if (not self.packsPuedenSatisfacer(consumo)) {
			tipoDeCliente.accion()
		}
	}
	method packsPuedenSatisfacer(consumo) = packsActivos.any({pack => pack.satisface(consumo)})
	method limpiarPacksVacios() {
		packsActivos.removeAllSuchThat({pack => pack.acabado() or pack.estaVencido()})
	}
}

// CONSUMO
class Consumo {
	const fecha	= new Date()
	const lineaQueLoRealizo

	method realizadoEntre(fecha1, fecha2) = fecha.between(fecha1, fecha2)
	//cantidadCreditoDisponibles >= consumo.costo()
	method cubiertoPorMBLibres(mbLibres) = false
	method cubiertoPorLlamadas(cantSegsDisp) = false
}

class ConsumoInternet inherits Consumo {
	var property cantidadMB = 0
	
	override method cubiertoPorMBLibres(mbLibres) = mbLibres >= cantidadMB
	method costo() = cantidadMB * empresa.precioPorMB()
}
class ConsumoLlamada inherits Consumo {
	var property cantidadSegs = 0
	
	override method cubiertoPorLlamadas(cantSegsDisp) = cantSegsDisp >= cantidadSegs
	method costo() = empresa.precioBase() + cantidadSegs * empresa.precioPorSeg()
}

// PACKS
class Pack {
	var consumos = []
	var vigencia = ilimitado
	
	method estaVencido() = vigencia.yaVencio()
	method satisface(consumo) = not self.estaVencido() and self.loCubre(consumo)
	method loCubre(consumo)
	method aplicar(consumo) {}
	method acabado() = false
}
class PackCredito inherits Pack {
	var cantidadCreditoDisponible = 100
	
	override method aplicar(consumo) {
		cantidadCreditoDisponible = cantidadCreditoDisponible - consumo.costo()
	}
	override method loCubre(consumo) = cantidadCreditoDisponible >= consumo.costo()
	override method acabado() = cantidadCreditoDisponible == 0
	
}
class PackMBLibres inherits Pack {
	var cantidadMBDisponibles = 100
	
	override method aplicar(consumo) {
		cantidadMBDisponibles = cantidadMBDisponibles - consumo.cantidadMB()
	}
	override method loCubre(consumo) = consumo.cubiertoPorMBLibres(cantidadMBDisponibles)
	override method acabado() = cantidadMBDisponibles == 0
}
class LlamadasGratis inherits Pack {
	var cantidadSegsDisponibles = 100
	
	override method aplicar(consumo) {
		cantidadSegsDisponibles = cantidadSegsDisponibles - consumo.cantidadSegs()
	}
	override method loCubre(consumo) = consumo.cubiertoPorLlamadas(cantidadSegsDisponibles)
	override method acabado() = cantidadSegsDisponibles == 0
}
class InternetIlimitado inherits Pack {
	var finDeSemana = []
	
	method hoy() = new Date()
	override method loCubre(consumo) = finDeSemana.contains(self.hoy())
}
class PackMBLibrePlusPlus inherits PackMBLibres {
	
	
}


object ilimitado {
	
	method yaVencio() = false
}
object vencimiento {
	var fecha
	
	method yaVencio() = fecha > new Date()
} 

object black {
	var registroDeDeudas = []
	
	method accion(consumo, linea) {
		registroDeDeudas.add(consumo)
	}
}
object platinum {
	method accion(consumo, linea) {
		linea.consumosRealizados().add(consumo)
	}
}
object comun {
	method accion(consumo) {
		self.error("No hay ningun pack en tu linea que te permita realizar ese consumo")
	}
}










