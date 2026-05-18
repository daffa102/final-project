<?php

namespace Laravel\Sanctum;

/**
 * @method mixed getKey()
 */
class PersonalAccessToken extends \Illuminate\Database\Eloquent\Model {}

namespace Laravel\Sanctum\Contracts;

/**
 * @method mixed getKey()
 */
interface HasAbilities {}
