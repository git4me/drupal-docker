<?php 
$I = new WebGuy($scenario);
$I->wantTo('see Drupal word in title ');
$I->amOnPage('/');
$I->seeInTitle('Kebab');