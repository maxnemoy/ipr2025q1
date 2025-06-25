# Clean Architecture

## Слои

1 - Presentation Layer:
    - UI (отображение данных)
    - Не содержит бизнес логики

2 - Application Layer:
    - Реализация сценариев (интеракторы, use case)

3 - Domain Layer:
    - Модели
    - Интерфейсы репозиториев, сервисов
    - В идеальном мире не должен быть подвязан на фреймворк

4 - Data Layer:
    - Реализации интерфейсов: дата провайдеры, сервисы
    - ДТО

## Какие слои обычно занимается elementary

Elementary - библиотека для организации Presentation Layer, иногда может затрагивать Application Layer

- View и WidgetModel - UI и стейт менеджер
- WidgetModel - может содержать простую бизнес-логику, но в идеале стараться избегать такого подхода

Elementary занимается Presentation Layer и в некоторых случаях, для реализации простых сценариев может залазить в Application Layer

## Какие слои в чистой архитектуре будет занимать bloc или redux

### Bloc

- В основном используется для управления состоянием UI. (Presentation Layer)

- Может содержать простую бизнес-логику, но лучший подход — вызывать из Bloc отдельные use case’ы или сервисы/интеракторы.

Redux
 - UI (Presentation Layer) но иногда реализует часть Application Layer (например, сложные middleware или thunks).

Хранит состояние UI, реагирует на экшены пользователя, обрабатывает события.

Не должен содержать логику доступа к данным — только взаимодействие с сервисами (через middleware).

Вывод:
И Bloc, и Redux — это в первую очередь инструменты Presentation Layer, но при плохом проектировании могут затягивать на себя часть Application Layer.


https://habr.com/ru/companies/surfstudio/articles/653655/
https://habr.com/ru/articles/522640/
https://www.chitai-gorod.ru/product/chistaya-arhitektura-iskusstvo-razrabotki-programmnogo-obespecheniya-2640391?ysclid=mcbamnfzu945570290
https://habr.com/ru/articles/766762/

