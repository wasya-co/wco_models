"use strict";

function find_touch(touch_list, id) {
	if (!touch_list) return null
	for (var i = 0; i < touch_list.length; i++) {
		if (touch_list[i].identifier === id) return touch_list[i]
	}
	return null
}

function RotationPad(container) {

	var mouseDown = false
	var last_x = 0
	var last_y = 0
	var self = this

	self.container = container
	self.rotationPad = $('<div class="rotation-pad"></div>')
	self.region = $('<div class="region"></div>')
	self.handle = $('<div class="handle"></div>')

	self.rotationPad.append(self.region).append(self.handle)
	self.container.append(self.rotationPad)

	var touch_id = null
	var ignore_mouse_until = 0

	function container_rect() {
		return self.container[0].getBoundingClientRect()
	}

	function in_look_zone(clientX, clientY) {
		var rect = container_rect()
		var x = clientX - rect.left
		var y = clientY - rect.top
		return x >= rect.width / 2 && x <= rect.width && y >= rect.height / 2 && y <= rect.height
	}

	function place_pad(clientX, clientY) {
		var rect = container_rect()
		var w = self.rotationPad.outerWidth()
		var h = self.rotationPad.outerHeight()
		self.rotationPad.css({
			left: clientX - rect.left - w / 2,
			top: clientY - rect.top - h / 2
		})
	}

	function begin_input(clientX, clientY) {
		mouseDown = true
		last_x = clientX
		last_y = clientY
		self.rotationPad.addClass('is-active')
		place_pad(clientX, clientY)
	}

	function end_input() {
		if (!mouseDown && touch_id === null) return
		mouseDown = false
		touch_id = null
		self.rotationPad.removeClass('is-active')
	}

	function move_input(clientX, clientY) {
		var dx = clientX - last_x
		var dy = clientY - last_y
		last_x = clientX
		last_y = clientY
		place_pad(clientX, clientY)
		if (dx === 0 && dy === 0) return
		var moveEvent = $.Event("YawPitch", {
			detail: {
				"deltaX": dx,
				"deltaY": dy
			},
			bubbles: false
		})
		$(self).trigger(moveEvent)
	}

	self.container.on("mousedown", function (event) {
		if (touch_id !== null || Date.now() < ignore_mouse_until) return
		if ($(event.target).closest('.movement-pad').length) return
		if (!in_look_zone(event.clientX, event.clientY)) return
		event.preventDefault()
		begin_input(event.clientX, event.clientY)
	})

	$(document).on("mouseup", function () {
		if (touch_id !== null) return
		end_input()
	})

	$(document).on("mousemove", function(event) {
		if (touch_id !== null || !mouseDown) return
		move_input(event.clientX, event.clientY)
	})

	self.container.on("touchstart", function (event) {
		if (touch_id !== null) return
		if ($(event.target).closest('.movement-pad').length) return
		var touch = event.originalEvent.changedTouches[0]
		if (!touch) return
		if (!in_look_zone(touch.clientX, touch.clientY)) return
		event.preventDefault()
		touch_id = touch.identifier
		ignore_mouse_until = Date.now() + 700
		begin_input(touch.clientX, touch.clientY)
	})

	$(document).on("touchmove", function(event) {
		if (touch_id === null) return
		var touch = find_touch(event.originalEvent.touches, touch_id)
		if (!touch) return
		move_input(touch.clientX, touch.clientY)
	})

	$(document).on("touchend touchcancel", function (event) {
		if (touch_id === null) return
		if (!find_touch(event.originalEvent.changedTouches, touch_id)) return
		ignore_mouse_until = Date.now() + 700
		end_input()
	})

}

RotationPad.prototype = {
	resetHandlePosition: function () {}
}

function MovementPad(container) {

	var mouseDown = false;
	var mouseStopped = false;
	var mouseStopTimeout, eventRepeatTimeout;
	var newLeft, newTop, distance, angle;
	var self = this;

	self.container = container;
	self.regionData = {};
	self.handleData = {};
	self.movementPad = $('<div class="movement-pad"></div>');
	self.region = $('<div class="region"></div>');
	self.handle = $('<div class="handle"></div>');

	self.movementPad.append(self.region).append(self.handle);
	self.container.append(self.movementPad);

	self.regionData.width = self.region.outerWidth();
	self.regionData.height = self.region.outerHeight();
	self.regionData.position = self.region.position();
	self.regionData.offset = self.region.offset();
	self.regionData.radius = self.regionData.width / 2;
	self.regionData.centerX = self.regionData.position.left + self.regionData.radius;
	self.regionData.centerY = self.regionData.position.top + self.regionData.radius;

	self.handleData.width = self.handle.outerWidth();
	self.handleData.height = self.handle.outerHeight();
	self.handleData.radius = self.handleData.width / 2;

	self.regionData.radius = self.regionData.width / 2 - self.handleData.radius;

	var touch_id = null
	var ignore_mouse_until = 0

	function begin_input(pageX, pageY) {
		self.regionData.offset = self.region.offset();
		mouseDown = true;
		self.handle.css("opacity", "1.0");
		update(pageX, pageY);
	}

	function end_input() {
		if (!mouseDown && touch_id === null) return
		mouseDown = false
		touch_id = null
		self.resetHandlePosition()
	}

	// Mouse events:
	self.region.on("mousedown", function (event) {
		if (touch_id !== null || Date.now() < ignore_mouse_until) return
		event.preventDefault();
		begin_input(event.pageX, event.pageY);
	});

	$(document).on("mouseup", function () {
		if (touch_id !== null) return
		end_input()
	});

	$(document).on("mousemove", function(event) {
		if (touch_id !== null || !mouseDown) return;
		update(event.pageX, event.pageY);
	});

	//Touch events:
	self.region.on("touchstart", function (event) {
		event.preventDefault();
		if (touch_id !== null) return
		var touch = event.originalEvent.changedTouches[0]
		if (!touch) return
		touch_id = touch.identifier
		ignore_mouse_until = Date.now() + 700
		begin_input(touch.pageX, touch.pageY);
	});

	$(document).on("touchmove", function(event) {
		if (touch_id === null) return
		var touch = find_touch(event.originalEvent.touches, touch_id)
		if (!touch) return
		update(touch.pageX, touch.pageY)
	});

	$(document).on("touchend touchcancel", function (event) {
		if (touch_id === null) return
		if (!find_touch(event.originalEvent.changedTouches, touch_id)) return
		ignore_mouse_until = Date.now() + 700
		end_input()
	});


	function update(pageX, pageY) {
		newLeft = (pageX - self.regionData.offset.left);
		newTop = (pageY - self.regionData.offset.top);

		// If handle reaches the pad boundaries.
		distance = Math.pow(self.regionData.centerX - newLeft, 2) + Math.pow(self.regionData.centerY - newTop, 2);
		if (distance > Math.pow(self.regionData.radius, 2)) {
			angle = Math.atan2((newTop - self.regionData.centerY), (newLeft - self.regionData.centerX));
			newLeft = (Math.cos(angle) * self.regionData.radius) + self.regionData.centerX;
			newTop = (Math.sin(angle) * self.regionData.radius) + self.regionData.centerY;
		}
		newTop = Math.round(newTop * 10) / 10;
		newLeft = Math.round(newLeft * 10) / 10;

		self.handle.css({
			top: newTop - self.handleData.radius,
			left: newLeft - self.handleData.radius
		});
		// console.log(newTop , newLeft);

		// Providing event and data for handling camera movement.
		var deltaX = self.regionData.centerX - parseInt(newLeft);
		var deltaY = self.regionData.centerY - parseInt(newTop);
		// Normalize x,y between -2 to 2 range.
		deltaX = -2 + (2+2) * (deltaX - (-self.regionData.radius)) / (self.regionData.radius - (-self.regionData.radius));
		deltaY = -2 + (2+2) * (deltaY - (-self.regionData.radius)) / (self.regionData.radius - (-self.regionData.radius));
		deltaX = Math.round(deltaX * 10) / 10;
		deltaY = Math.round(deltaY * 10) / 10;
		// console.log(deltaX, deltaY);

		sendEvent(deltaX, deltaY, 0);
	}

	function sendEvent(dx, dy, middle) {
		if (!mouseDown) {
			clearTimeout(eventRepeatTimeout);
			var stopEvent = $.Event("stopMove", {
				bubbles: false
			});
			$(self).trigger(stopEvent);

			return;
		}

		clearTimeout(eventRepeatTimeout);
		eventRepeatTimeout = setTimeout(function() {
			sendEvent(dx, dy, middle);
		}, 5);

		var moveEvent = $.Event("move", {
			detail: {
				"deltaX": dx,
				"deltaY": dy,
				"middle": middle
			},
			bubbles: false
		});
		$(self).trigger(moveEvent);
	}

	self.resetHandlePosition();
};

MovementPad.prototype = {
	resetHandlePosition: function () {
		this.handle.animate({
			top: this.regionData.centerY - this.handleData.radius,
			left: this.regionData.centerX - this.handleData.radius,
			opacity: 0.1
		}, "fast");
	}
};


function TouchControls(container, camera, options) {

	var self = this;
	self.config = $.extend({
		speedFactor: 0.5,
		delta: 1,
		rotationFactor: 0.002,
		maxPitch: 55,
		hitTest: true,
		hitTestDistance: 40
	}, options);

	var container = container;
	var isRightMouseDown = false;
	var rotationMatrices = [];
	var hitObjects = [];

	var moveForward = false;
	var moveBackward = false;
	var moveLeft = false;
	var moveRight = false;
	var lockMoveForward = false;
	var lockMoveBackward = false;
	var lockMoveLeft = false;
	var lockMoveRight = false;

	var ztouch = 1, xtouch = 1;
	var PI_2 = Math.PI / 2;
	var maxPitch = self.config.maxPitch * Math.PI / 180;
	var velocity = new THREE.Vector3(0, 0, 0);

	var cameraHolder = new THREE.Object3D();
	cameraHolder.name = "cameraHolder";
	cameraHolder.add(camera);

	self.scene = null;
	self.fpsBody = new THREE.Object3D();
	self.fpsBody.add(cameraHolder);
	self.enabled = true
	self.stick_x = 0
	self.stick_y = 0;

	self.mouse = new THREE.Vector2();

	// Creating rotation pad:
	self.rotationPad = new RotationPad(container);
	$(self.rotationPad).on("YawPitch", function(event) {
		var rotation = calculateCameraRotation(event.detail.deltaX, event.detail.deltaY);
		self.setRotation(rotation.rx, rotation.ry);
	});

	// Creating movement pad:
	self.movementPad = new MovementPad(container);
	$(self.movementPad).on("move", function(event) {
		self.stick_x = -event.detail.deltaX / 2
		self.stick_y = event.detail.deltaY / 2
		ztouch = Math.abs(event.detail.deltaY);
		xtouch = Math.abs(event.detail.deltaX);

		if (event.detail.deltaY == event.detail.middle) {
			ztouch = 1;
			moveForward = moveBackward = false;
		} else {
			if (event.detail.deltaY > event.detail.middle) {
				moveForward = true;
				moveBackward = false;
			}
			else if (event.detail.deltaY < event.detail.middle) {
				moveForward = false;
				moveBackward = true;
			}
		}

		if (event.detail.deltaX == event.detail.middle) {
			xtouch = 1;
			moveRight = moveLeft = false;
		} else {
			if (event.detail.deltaX < event.detail.middle) {
				moveRight = true;
				moveLeft = false;
			}
			else if (event.detail.deltaX > event.detail.middle) {
				moveRight = false;
				moveLeft = true;
			}
		}
	});
	$(self.movementPad).on("stopMove", function(event) {
		ztouch = xtouch = 1;
		self.stick_x = 0
		self.stick_y = 0
		moveForward = moveBackward = moveLeft = moveRight = false;
	});

	container.on("contextmenu", onContextMenu);
	container.on("mousedown", onMouseDown);
	container.on("mouseup", onMouseUp);

	$(document).on("keydown", onKeyDown);
	$(document).on("keyup", onKeyUp);
	$(document).on("mousemove", onMouseMove);
	$(document).on("mouseout", onMouseOut);

	prepareRotationMatrices();

	//
	// Events:
	//
	function onContextMenu(event) {
		event.preventDefault();
	};

	function onMouseDown(event) {

		if (self.enabled && event.button === 2) {
			isRightMouseDown = true;
			event.preventDefault();
			event.stopPropagation();
		}
	};

	function onMouseUp(event) {

		if (self.enabled && event.button === 2) {
			isRightMouseDown = false;
		}
	};

	function onMouseMove(event) {

		self.mouse.x = (event.clientX / window.innerWidth) * 2 - 1;
		self.mouse.y = -(event.clientY / window.innerHeight) * 2 + 1;

		if (!self.enabled || !isRightMouseDown) return;

		var movementX = event.originalEvent.movementX || event.originalEvent.mozMovementX || event.originalEvent.webkitMovementX || 0;
		var movementY = event.originalEvent.movementY || event.originalEvent.mozMovementY || event.originalEvent.webkitMovementY || 0;
		var rotation = calculateCameraRotation(-1 * movementX, -1 * movementY);

		// console.log(self.mouse, "\n", movementX, rotation);

		self.setRotation(rotation.rx, rotation.ry);

		// updateNavPad();
	};

	function onMouseOut(e) {
		isRightMouseDown = false;
		// self.stopMouseMoving();
	};

	function onKeyDown(e) {

		if (!self.enabled) return;

		switch (e.keyCode) {

			case 38: // up
			case 87: // w
				moveForward = true;
				break;

			case 37: // left
			case 65: // a
				moveLeft = true;
				break;

			case 40: // down
			case 83: // s
				moveBackward = true;
				break;

			case 39: // right
			case 68: // d
				moveRight = true;
				break;
		}
	};

	function onKeyUp(e) {

		switch (e.keyCode) {

			case 38: // up
			case 87: // w
				moveForward = false;
				break;

			case 37: // left
			case 65: // a
				moveLeft = false;
				break;

			case 40: // down
			case 83: // a
				moveBackward = false;
				break;

			case 39: // right
			case 68: // d
				moveRight = false;
				break;

		}
	};

	//
	// Private functions:
	//
	function prepareRotationMatrices() {

		var rotationMatrixF = new THREE.Matrix4();
		rotationMatrixF.makeRotationY(0);
		rotationMatrices.push(rotationMatrixF); // forward direction.

		var rotationMatrixB = new THREE.Matrix4();
		rotationMatrixB.makeRotationY(180 * Math.PI / 180);
		rotationMatrices.push(rotationMatrixB);

		var rotationMatrixL = new THREE.Matrix4();
		rotationMatrixL.makeRotationY(90 * Math.PI / 180);
		rotationMatrices.push(rotationMatrixL);

		var rotationMatrixR = new THREE.Matrix4();
		rotationMatrixR.makeRotationY((360 - 90) * Math.PI / 180);
		rotationMatrices.push(rotationMatrixR);
	};

	function calculateCameraRotation(dx, dy, factor) {
		var factor = factor ? factor : self.config.rotationFactor;
		var ry = self.fpsBody.rotation.y - (dx * factor);
		var rx = cameraHolder.rotation.x - (dy * factor);
		rx = Math.max(-maxPitch, Math.min(maxPitch, rx));

		return {
			rx: rx,
			ry: ry
		};
	};

	function lockDirectionByIndex(index) {
		if (index == 0)
			self.lockMoveForward(true);
		else if (index == 1)
			self.lockMoveBackward(true);
		else if (index == 2)
			self.lockMoveLeft(true);
		else if (index == 3)
			self.lockMoveRight(true);
	}

	//
	// Public functions:
	//
	self.update = function() {
		if (!self.enabled) return;
		if (self.config.hitTest)
			self.hitTest();

		velocity.x += (-1 * velocity.x) * 0.75 * self.config.delta;
		velocity.z += (-1 * velocity.z) * 0.75 * self.config.delta;

		if (moveForward && !lockMoveForward) velocity.z -= ztouch * self.config.speedFactor * self.config.delta;
		if (moveBackward && !lockMoveBackward) velocity.z += ztouch * self.config.speedFactor * self.config.delta;

		if (moveLeft && !lockMoveLeft) velocity.x -= xtouch * self.config.speedFactor * self.config.delta;
		if (moveRight && !lockMoveRight) velocity.x += xtouch * self.config.speedFactor * self.config.delta;

		self.fpsBody.translateX(velocity.x);
		self.fpsBody.translateY(velocity.y);
		self.fpsBody.translateZ(velocity.z);
	};

	self.hitTest = function() {
		self.unlockAllDirections();
		hitObjects = [];
		var cameraDirection = self.getDirection2(new THREE.Vector3(0, 0, 0)).clone();

		for (var i = 0; i < 4; i++) {
			// Applying rotation for each direction:
			var direction = cameraDirection.clone();
			direction.applyMatrix4(rotationMatrices[i]);

			var rayCaster = new THREE.Raycaster(self.fpsBody.position, direction);
			var intersects = rayCaster.intersectObject(self.scene, true);
			if ((intersects.length > 0 && intersects[0].distance < self.config.hitTestDistance)) {
				lockDirectionByIndex(i);
				hitObjects.push(intersects[0]);
				// console.log(intersects[0].object.name, i);
			}
		}

		return hitObjects;
	};

	self.getDirection2 = function(v) {
		var self = this;
		var direction = new THREE.Vector3(0, 0, -1);
		var rotation = new THREE.Euler(0, 0, 0, "YXZ");
		var rx = self.fpsBody.getObjectByName("cameraHolder").rotation.x;;
		var ry = self.fpsBody.rotation.y;

		// console.log("DIRECTION:", this);
		rotation.set(rx, ry, 0);
		v.copy(direction).applyEuler(rotation);
		// console.log(v);
		return v;
	};

	self.getDirection = function() {
		var self = this;
		var rx = 0;
		var ry = 0;
		var direction = new THREE.Vector3(0, 0, -1);
		var rotation = new THREE.Euler(0, 0, 0, "YXZ");

		// console.log("DIRECTION:", this);
		if (self != undefined) {
			rx = self.fpsBody.getObjectByName("cameraHolder").rotation.x;
			ry = self.fpsBody.rotation.y;
			console.log(rx, ry);
		}
		// var camHolder = self.fpsBody.getObjectByName("cameraHolder");

		return function(v) {
			rotation.set(rx, ry, 0);
			v.copy(direction).applyEuler(rotation);
			// console.log(v);
			return v;
		}
	}();

	self.moveLeft = function() {
		return moveLeft;
	};

	self.moveRight = function() {
		return moveRight;
	};

	self.moveForward = function() {
		return moveForward;
	};

	self.moveBackward = function() {
		return moveBackward;
	};

	self.lockMoveForward = function(boolean) {
		lockMoveForward = boolean;
	};

	self.lockMoveBackward = function(boolean) {
		lockMoveBackward = boolean;
	};

	self.lockMoveLeft = function(boolean) {
		lockMoveLeft = boolean;
	};

	self.lockMoveRight = function(boolean) {
		lockMoveRight = boolean;
	};

	self.unlockAllDirections = function() {
		self.lockMoveForward(false);
		self.lockMoveBackward(false);
		self.lockMoveLeft(false);
		self.lockMoveRight(false);
	};
};

TouchControls.prototype = {
	addToScene: function(scene) {
		this.scene = scene;
		scene.add(this.fpsBody);
	},

	setPosition: function(x, y, z) {
		this.fpsBody.position.set(x, y, z);
	},

	stopMouseMoving: function() {
		isRightMouseDown = false;
	},

	setRotation: function(x, y) {
		var camHolder = this.fpsBody.getObjectByName("cameraHolder");

		if (x !== null)
			camHolder.rotation.x = x;

		if (y !== null)
			this.fpsBody.rotation.y = y;
	},

	getHitObjects: function() {
		return hitObjects;
	}

};

export default {
  TouchControls,
  MovementPad,
  RotationPad,
}

window.TouchControls = TouchControls
window.MovementPad = MovementPad
window.RotationPad = RotationPad
