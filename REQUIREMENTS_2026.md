# Requerimientos de Mejoras — The Site DeeJay Schedule
**Fecha:** 2026-05-19  
**Estado:** Pendiente de clarificaciones antes de iniciar desarrollo

---

## Resumen de funcionalidades solicitadas

### RF-01 — Nuevas opciones de horas en suscripciones
Agregar soporte para suscripciones de **4 horas** (ya existe el enum `Cuatro` pero no estaba visible en el formulario) y **5 horas** (nueva opción). También agregar soporte para **clases de 1 hora** dentro de las suscripciones.

**Estado actual del código:**
- `Suscription.hours` enum: `[:Dos, :Cuatro, :Doce, :Full, :Diez]`
- Cada reserva ocupa exactamente 2 horas (hardcoded: `count * 2` en el controlador y en JS)
- No existe un valor de 1 hora ni de 5 horas en el enum

**Cambios requeridos:**
- Agregar `Cinco` (5h) y `Una` (1h) al enum `hours` de `Suscription`
- Cambiar la lógica de conteo de horas para que cada `Reservation` almacene su propia duración (`duration_hours`), en lugar de asumir siempre 2h
- Actualizar el calendario frontend para permitir crear reservas de 1h o 2h según el tipo de suscripción o según elección del usuario

---

### RF-02 — Múltiples suscripciones activas por estudiante
Un estudiante puede tener hasta **dos suscripciones activas simultáneamente**. Al momento de agendar una práctica, debe seleccionar de una lista desplegable cuál suscripción quiere usar.

**Estado actual del código:**
- `SchedulesController` usa `Suscription.find_by(user_id: ..., status: true)` — retorna solo la primera activa
- La vista del calendario pasa `#suscription_id` como campo oculto con un único valor
- El JS de la vista de calendario no tiene lógica de selección de suscripción

**Cambios requeridos:**
- Modificar `SchedulesController#index` para cargar todas las suscripciones activas del usuario (no solo la primera)
- Agregar un `<select>` en la vista del calendario para que el estudiante escoja qué suscripción usar antes de crear una reserva
- Actualizar `SchedulesController#new` y `#destroy` para trabajar con la suscripción seleccionada
- Actualizar `RoomsController` para cargar todas las suscripciones activas del usuario (panel informativo)

---

### RF-03 — Fecha de vencimiento de suscripciones
Cada suscripción debe tener una **fecha de vencimiento**. Por defecto se calcula como 6 meses desde la fecha de creación, pero el administrador/instructor puede personalizarla.

**Estado actual del código:**
- La tabla `suscriptions` no tiene columna `expires_at`
- El campo `status` (boolean) es el único mecanismo de activación/desactivación

**Cambios requeridos:**
- Nueva migración: agregar columna `expires_at DATE` a `suscriptions`
- En el modelo `Suscription`, asignar `expires_at = created_at + 6 meses` como valor por defecto antes de guardar
- En el formulario de creación/edición de suscripciones, agregar campo para personalizar la fecha de vencimiento:
  - Opción A: Ingresar número de meses (campo numérico)
  - Opción B: Seleccionar fecha exacta con un datepicker (Air Datepicker ya está disponible)
- Agregar tarea o job que desactiva (`status = false`) suscripciones vencidas automáticamente, O verificar el vencimiento en tiempo real al acceder al calendario

---

### RF-04 — Panel informativo de suscripciones para el estudiante
El estudiante debe ver en su **pantalla de inicio** (actualmente `rooms#index`) un panel que muestre:
- Las suscripciones activas que tiene
- La fecha de vencimiento de cada una
- Las horas restantes de cada una

**Estado actual del código:**
- `rooms/index.html.erb` muestra solo el nombre del programa activo (`@active_suscription.name`)
- `RoomsController` carga una sola suscripción activa

**Cambios requeridos:**
- Actualizar `RoomsController#index` para cargar todas las suscripciones activas con sus horas usadas
- Crear un partial o sección en `rooms/index.html.erb` con tarjetas informativas por suscripción
- Calcular horas usadas por suscripción a partir de `Reservation.where(suscription_id: id).sum(:duration_hours)` (requiere RF-01)
- Mostrar horas restantes = `suscrip_hours - horas_usadas`

---

### RF-05 — Bloqueo de franjas horarias por sala
Los instructores y administradores deben poder **bloquear rangos de horas en salas específicas** para que ningún estudiante pueda reservar en ese horario.

**Estado actual del código:**
- No existe ninguna entidad de "bloqueo" en la base de datos
- El calendar muestra todos los slots como disponibles si no hay una reserva
- La tabla `schedules` existe pero está vestigial (no se usa en la lógica de negocio actual)

**Cambios requeridos:**
- Nueva tabla `blocked_slots`: `room_id`, `start_hour` (integer), `end_hour` (integer), `block_date` (date), `reason` (string, opcional), `created_by_user_id`
- Nueva interfaz para instructores/admins: formulario o click directo en el calendario para crear un bloqueo
- En `SchedulesController#new`, verificar si el slot solicitado está bloqueado antes de crear la reserva
- En el frontend (FullCalendar), mostrar los bloques como eventos de color diferente (no clickeables por estudiantes)
- Los bloques deben aparecer en el calendario de cada sala

---

## Análisis de impacto técnico

| Área | Archivos afectados | Complejidad |
|------|--------------------|-------------|
| Enum hours | `suscription.rb`, migración, `suscriptions/new.html.erb`, `suscriptions/edit.html.erb`, `schedules_controller.rb` | Baja |
| Duración por reserva | Migración `reservations`, `schedules_controller.rb`, `application.js` | Media |
| Múltiples suscripciones | `schedules_controller.rb`, `schedules/index.html.erb`, `application.js`, `rooms_controller.rb` | Media-Alta |
| Fecha de vencimiento | Migración `suscriptions`, `suscription.rb`, formularios, `suscriptions_controller.rb` | Media |
| Panel informativo | `rooms_controller.rb`, `rooms/index.html.erb` | Baja-Media |
| Bloqueo de horarios | Nueva migración, nuevo modelo, nuevo controlador, `schedules_controller.rb`, `application.js` | Alta |

---

## Preguntas de clarificación antes de iniciar desarrollo

### Sobre RF-01 — Duración de las clases

**P1.** El sistema actual asume siempre bloques de 2 horas. Con las "clases de 1 hora", ¿cómo funciona en la práctica?
- (a) La duración la determina el tipo de suscripción (ej. suscripción tipo "Demo" → siempre 1h, tipo "MV1" → siempre 2h)
- (b) El estudiante escoge al momento de reservar si quiere bloquear 1h o 2h
- (c) Otra lógica

**P2.** El calendario actualmente muestra franjas de 2 horas. Si se habilitan bloques de 1 hora, ¿se debe cambiar el tamaño mínimo del slot en el calendario, o se puede reservar de 1h pero el bloque visualmente sigue siendo de 2h?

**P3.** `Cuatro` horas ya existe en el enum pero no aparecía en el formulario (no estaba en el `<select>` del HTML). ¿Quieres habilitarlo también, o solo agregar `Cinco` y `Una`?

---

### Sobre RF-02 — Múltiples suscripciones activas

**P4.** ¿Cuál es el máximo de suscripciones activas simultáneas por estudiante? ¿Exactamente 2, o puede ser más?

**P5.** Cuando el estudiante abre el calendario de una sala, ¿la lista desplegable de suscripciones debe mostrar solo las que tienen acceso a esa sala específica (según `rooms` de cada suscripción), o todas las activas?

**P6.** Si un estudiante tiene dos suscripciones activas pero una ya no tiene horas disponibles, ¿se debe ocultar esa suscripción del desplegable, o debe aparecer con indicación de "sin horas"?

---

### Sobre RF-03 — Fecha de vencimiento

**P7.** Cuando una suscripción llega a su fecha de vencimiento, ¿qué debe pasar?
- (a) Se desactiva automáticamente (requiere un job recurrente o verificación en tiempo real)
- (b) El admin/instructor la desactiva manualmente cuando la ve vencida
- (c) El sistema muestra una alerta pero no la bloquea automáticamente

**P8.** ¿Las suscripciones existentes en la BD (sin `expires_at`) deben recibir una fecha de vencimiento al migrar? ¿Calculada desde `created_at + 6 meses`, o se dejan sin fecha hasta que el admin la asigne?

**P9.** ¿Debe enviarse alguna notificación (por ejemplo, email) al estudiante o al admin cuando una suscripción esté próxima a vencer? (Nota: el email está actualmente deshabilitado en la app.)

---

### Sobre RF-05 — Bloqueo de horarios

**P10.** Los bloqueos, ¿deben ser solo para una fecha específica (ej. bloquear el viernes 23-may de 10am a 12pm), o también deben poder ser recurrentes (ej. bloquear todos los lunes de 10am a 12pm)?

**P11.** ¿Cómo se crean los bloqueos? 
- (a) Formulario separado en el panel de administración
- (b) Click/drag directamente en el calendario de la sala (como cuando se crea una reserva)
- (c) Ambas opciones

**P12.** ¿Los bloqueos deben verse en el calendario para todos los usuarios (estudiantes, instructores, admins), o solo para instructores/admins?

**P13.** ¿Un bloqueo puede tener un motivo o descripción visible? (ej. "Mantenimiento", "Clase grupal")

---

### Sobre el panel informativo (RF-04)

**P14.** Para el cálculo de "horas restantes", ¿se deben considerar solo las reservas futuras (práctica pendiente), o todas las reservas históricas también restan horas?  
*(La lógica actual resta TODAS las reservas, no solo las pasadas. Si alguien cancela, las horas se devuelven.)*

---

## Orden de desarrollo sugerido

Dado el nivel de interdependencia entre los requerimientos, se sugiere el siguiente orden:

1. **RF-01 parcial** — Agregar `Cinco` y `Una` al enum, agregar `duration_hours` a `Reservation`
2. **RF-03** — Agregar `expires_at` a `Suscription`
3. **RF-02** — Soporte a múltiples suscripciones activas + desplegable en calendario
4. **RF-04** — Panel informativo en pantalla de inicio
5. **RF-01 completo** — Lógica de reservas de 1h en calendario
6. **RF-05** — Bloqueo de franjas horarias

---

## Decisiones tomadas (2026-05-19)

| # | Pregunta | Decisión |
|---|----------|----------|
| P1 | Duración de la clase | El estudiante escoge al crear la reserva: 1h o 2h |
| P2 | Opciones de horas | Habilitar `Cuatro` (4h) y `Doce` (12h) en el formulario; agregar `Una` (1h) y `Cinco` (5h) **al final** del enum para no desplazar valores enteros en la BD |
| P3 | Filtro suscripciones en calendario | Solo mostrar las suscripciones que tienen acceso a la sala actual (campo `rooms`) |
| P4 | Vencimiento automático | La suscripción se bloquea en tiempo real al intentar reservar si ya venció; no aparece en el desplegable |
| P5 | Suscripciones existentes sin fecha | Se dejan con `expires_at = NULL` (sin vencimiento), el admin les asigna fecha manualmente cuando quiera |
| P6 | Bloqueos recurrentes | No. Solo fechas específicas puntuales |
| P7 | Cómo crear bloqueos | Clic directo en el calendario + texto de instrucciones visible para instructores/admins |
| P8 | Visibilidad bloqueos para estudiantes | Visibles en otro color (no clickeables), sin mostrar motivo |
| P9 | Cálculo horas restantes | Todas las reservas (pasadas + futuras) restan horas, igual que la lógica actual |

---

*Documento generado el 2026-05-19. Decisiones confirmadas — listo para iniciar desarrollo.*
