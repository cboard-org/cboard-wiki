/* Title: High level description of the UI  and modules */

## UI Components

#### App

Main Component where Cboard routes and sub-components are defined.

#### Board

It renders a grid with the tiles defined for the current board. If it does not have board data, it will try to fetch the board data from the API.

There are other components like:

- **BoardShare**: share board dialog
- **EditToolbar**: board toolbar with add/remove/save buttons
- **NavBar**: board title, lock button and buttons like: print, share, settings, etc.
- **Output**: top bar with pictures that allow Cboard to speech when is clicked.
- **Tile**: board tile component.

#### Communicator

- **CommunicatorToolbar**: displays Communicator name and boards.
- **CommunicatorDialog**: lists communicator boards, public boards and own boards.

#### Settings

Cboard Settings major component. It contains other settings componentes like:

- About
- Display
- Export
- Import
- Language
- Navigation
- People
- Scanning
- Speech

#### UI

Contains Cboard common components.
