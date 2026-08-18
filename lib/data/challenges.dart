import '../models/nutrition_models.dart';

const dailyChallenges = <DailyChallenge>[
  DailyChallenge(
    id: 'water_4',
    title: 'Tomar 4 vasos de agua',
    description: 'Marca este reto cuando tomes al menos 4 vasos durante el dia.',
    reward: '+10 estrellas de hidratacion',
  ),
  DailyChallenge(
    id: 'fruit_1',
    title: 'Comer una fruta',
    description: 'Elige una fruta natural en desayuno o merienda.',
    reward: '+10 estrellas de energia',
  ),
  DailyChallenge(
    id: 'vegetable_1',
    title: 'Probar una verdura',
    description: 'Agrega una verdura al almuerzo o cena.',
    reward: '+10 estrellas de color',
  ),
  DailyChallenge(
    id: 'swap_soda',
    title: 'Cambiar gaseosa por agua',
    description: 'Si quieres algo dulce, prueba agua con fruta.',
    reward: '+15 estrellas de decision saludable',
  ),
  DailyChallenge(
    id: 'walk_1500',
    title: 'Caminar 1500 pasos',
    description: 'En Android se completa solo cuando el celular detecta los pasos.',
    reward: '+20 estrellas de movimiento',
    stepGoal: 1500,
  ),
];
