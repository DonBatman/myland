# AIO - Land Claim Mod README

## Overview

The AIO Land Claim mod is designed for Minetest, allowing players to claim chunks of land within the game world. Once claimed, these areas provide protection against various natural elements such as lava, water, and fire from other players. The mod includes functionality for claiming, unclaiming, checking ownership, and managing access permissions.

## Features

- **Chunk Claiming:** Players can claim chunks to prevent others from altering them.
- **Lava, Water, and Fire Protection:** Stops the spread of these elements into claimed areas from adjacent unprotected land.
- **Access Management:** Owners can grant or revoke other players' access to their claimed chunks.

## Usage Instructions

### Commands

#### Claiming a Chunk
- `/claim`: Claims the chunk you are currently standing in. The command will notify if the chunk is already owned by another player.

#### Unclaiming a Chunk
- `/unclaim`: Unclaims your current chunk, allowing others to interact with it freely.

#### Checking Ownership
- `/is_owner`: Checks if you own the chunk where you're currently positioned and provides appropriate feedback.

### Access Management

- **Grant Access**
  - `/give_claim <player_name>`: Grants another player access to modify your claimed chunk.
  
- **Revoke Access**
  - `/revoke_claim <player_name>`: Revokes a previously granted permission for a player to interact with your claimed chunk.

### Interactions with Other Players

Players attempting to alter chunks that they do not own will receive a notification stating the owner's name and be prevented from making changes. If an attempt is made by non-owners, such actions are restricted unless they have been explicitly granted access.

